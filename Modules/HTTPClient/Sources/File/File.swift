@_exported import Core
import CLibvenice

public enum FileMode {
    case read
    case createWrite
    case truncateWrite
    case appendWrite
    case readWrite
    case createReadWrite
    case truncateReadWrite
    case appendReadWrite
}

extension FileMode {
    var value: Int32 {
        switch self {
        case .read: return O_RDONLY
        case .createWrite: return (O_WRONLY | O_CREAT | O_EXCL)
        case .truncateWrite: return (O_WRONLY | O_CREAT | O_TRUNC)
        case .appendWrite: return (O_WRONLY | O_CREAT | O_APPEND)
        case .readWrite: return (O_RDWR)
        case .createReadWrite: return (O_RDWR | O_CREAT | O_EXCL)
        case .truncateReadWrite: return (O_RDWR | O_CREAT | O_TRUNC)
        case .appendReadWrite: return (O_RDWR | O_CREAT | O_APPEND)
        }
    }
}

public final class File : Stream {
    fileprivate var file: mfile?
    public fileprivate(set) var closed = false
    public fileprivate(set) var path: String? = nil

    public func cursorPosition() throws -> Int {
        let position = Int(filetell(file))
        try ensureLastOperationSucceeded()
        return position
    }

    public func seek(cursorPosition: Int) throws -> Int {
        let position = Int(fileseek(file, off_t(cursorPosition)))
        try ensureLastOperationSucceeded()
        return position
    }

    public var length: Int {
        return Int(filesize(self.file))
    }

    public var cursorIsAtEndOfFile: Bool {
        return fileeof(file) != 0
    }

    public lazy var fileExtension: String? = {
        guard let path = self.path else {
            return nil
        }

        guard let fileExtension = path.split(separator: ".").last else {
            return nil
        }

        if fileExtension.split(separator: "/").count > 1 {
            return nil
        }

        return fileExtension
    }()

    init(file: mfile) {
        self.file = file
    }

    public convenience init(fileDescriptor: FileDescriptor) throws {
        let file = fileattach(fileDescriptor)
        try ensureLastOperationSucceeded()
        self.init(file: file!)
    }

    public convenience init(path: String, mode: FileMode = .read) throws {
        let file = fileopen(path, mode.value, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH)
        try ensureLastOperationSucceeded()
        self.init(file: file!)
        self.path = path
    }

    deinit {
        if let file = file, !closed {
            fileclose(file)
        }
    }
}

extension File {
    public func write(_ data: Data, length: Int, deadline: Double) throws -> Int {
        try ensureFileIsOpen()

        let bytesWritten = data.withUnsafeBytes {
            filewrite(file, $0, length, deadline.int64milliseconds)
        }

        if bytesWritten == 0 {
            try ensureLastOperationSucceeded()
        }

        return bytesWritten
    }

    public func read(into buffer: inout Data, length: Int, deadline: Double) throws -> Int {
        try ensureFileIsOpen()

        let bytesRead = buffer.withUnsafeMutableBytes {
            filereadlh(file, $0, 1, length, deadline.int64milliseconds)
        }

        if bytesRead == 0 {
            try ensureLastOperationSucceeded()
        }

        return bytesRead
    }

    //    public func read(_ byteCount: Int, deadline: Double = .never) throws -> Data {
    //        try ensureFileIsOpen()
    //
    //        var data = Data(count: byteCount)
    //        let received = data.withUnsafeMutableBytes {
    //            fileread(file, $0, data.count, deadline.int64milliseconds)
    //        }
    //
    //        let receivedData = Data(data.prefix(received))
    //        try ensureLastOperationSucceeded()
    //
    //        return receivedData
    //    }

    public func readAll(bufferSize: Int = 2048, deadline: Double = .never) throws -> Data {
        var inputBuffer = Data(count: bufferSize)
        var outputBuffer = Data()

        while true {
            let inputRead = try read(into: &inputBuffer, deadline: deadline)

            if inputRead == 0 || cursorIsAtEndOfFile {
                break
            }

            inputBuffer.withUnsafeBytes {
                outputBuffer.append($0, count: inputRead)
            }
        }

        return outputBuffer
    }

    public func flush(deadline: Double) throws {
        try ensureFileIsOpen()
        fileflush(file, deadline.int64milliseconds)
        try ensureLastOperationSucceeded()
    }

    public func close() {
        if !closed {
            fileclose(file)
        }
        closed = true
    }

    private func ensureFileIsOpen() throws {
        if closed {
            throw StreamError.closedStream(data: Data())
        }
    }
}

extension File {
    public static var workingDirectory: String {
        var buffer = [Int8](repeating: 0, count: Int(MAXNAMLEN))
        let workingDirectory = getcwd(&buffer, buffer.count)
        return String(cString: workingDirectory!)
    }

    public static func changeWorkingDirectory(path: String) throws {
        if chdir(path) == -1 {
            try ensureLastOperationSucceeded()
        }
    }

    public static func contentsOfDirectory(path: String) throws -> [String] {
        var contents: [String] = []

        guard let dir = opendir(path) else {
            try ensureLastOperationSucceeded()
            return []
        }

        defer {
            closedir(dir)
        }

        let excludeNames = [".", ".."]

        while let file = readdir(dir) {
            let entry: UnsafeMutablePointer<dirent> = file

            if let entryName = withUnsafeMutablePointer(to: &entry.pointee.d_name, { (ptr) -> String? in
                let entryPointer = unsafeBitCast(ptr, to: UnsafePointer<CChar>.self)
                return String(validatingUTF8: entryPointer)
            }) {
                if !excludeNames.contains(entryName) {
                    contents.append(entryName)
                }
            }
        }

        return contents
    }

    public static func fileExists(path: String) -> Bool {
        var s = stat()
        return lstat(path, &s) >= 0
    }

    public static func isDirectory(path: String) -> Bool {
        var s = stat()
        if lstat(path, &s) >= 0 {
            if (s.st_mode & S_IFMT) == S_IFLNK {
                if stat(path, &s) >= 0 {
                    return (s.st_mode & S_IFMT) == S_IFDIR
                }
                return false
            }
            return (s.st_mode & S_IFMT) == S_IFDIR
        }
        return false
    }

    public static func createDirectory(path: String, withIntermediateDirectories createIntermediates: Bool = false) throws {
        if createIntermediates {
            let (exists, directory) = (fileExists(path: path), isDirectory(path: path))
            if !exists {
                let parent = path.dropLastPathComponent()

                if !fileExists(path: parent) {
                    try createDirectory(path: parent, withIntermediateDirectories: true)
                }
                if mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO) == -1 {
                    try ensureLastOperationSucceeded()
                }
            } else if directory {
                return
            } else {
                throw SystemError.fileExists
            }
        } else {
            if mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO) == -1 {
                try ensureLastOperationSucceeded()
            }
        }
    }

    public static func removeFile(path: String) throws {
        if unlink(path) != 0 {
            try ensureLastOperationSucceeded()
        }
    }

    public static func removeDirectory(path: String) throws {
        if fileremove(path) != 0 {
            try ensureLastOperationSucceeded()
        }
    }
}

// Warning: We're gonna need this when we split Venice from Quark in the future

// extension String {
//     func split(separator: Character, maxSplits: Int = .max, omittingEmptySubsequences: Bool = true) -> [String] {
//         return characters.split(separator: separator, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences).map(String.init)
//     }
//
//    public func has(prefix: String) -> Bool {
//        return prefix == String(self.characters.prefix(prefix.characters.count))
//    }
//
//    public func has(suffix: String) -> Bool {
//        return suffix == String(self.characters.suffix(suffix.characters.count))
//    }
//}

extension String {
    func dropLastPathComponent() -> String {
        let string = self.fixSlashes()

        if string == "/" {
            return string
        }

        switch string.startOfLastPathComponent {

        // relative path, single component
        case string.startIndex:
            return ""

        // absolute path, single component
        case string.index(after: startIndex):
            return "/"

        // all common cases
        case let startOfLast:
            return String(string.characters.prefix(upTo: string.index(before: startOfLast)))
        }
    }

    func fixSlashes(compress: Bool = true, stripTrailing: Bool = true) -> String {
        if self == "/" {
            return self
        }

        var result = self

        if compress {
            result.withMutableCharacters { characterView in
                let startPosition = characterView.startIndex
                var endPosition = characterView.endIndex
                var currentPosition = startPosition

                while currentPosition < endPosition {
                    if characterView[currentPosition] == "/" {
                        var afterLastSlashPosition = currentPosition
                        while afterLastSlashPosition < endPosition && characterView[afterLastSlashPosition] == "/" {
                            afterLastSlashPosition = characterView.index(after: afterLastSlashPosition)
                        }
                        if afterLastSlashPosition != characterView.index(after: currentPosition) {
                            characterView.replaceSubrange(currentPosition ..< afterLastSlashPosition, with: ["/"])
                            endPosition = characterView.endIndex
                        }
                        currentPosition = afterLastSlashPosition
                    } else {
                        currentPosition = characterView.index(after: currentPosition)
                    }
                }
            }
        }

        if stripTrailing && result.has(suffix: "/") {
            result.remove(at: result.characters.index(before: result.characters.endIndex))
        }

        return result
    }

    var startOfLastPathComponent: String.CharacterView.Index {
        precondition(!has(suffix: "/") && characters.count > 1)

        let characterView = characters
        let startPos = characterView.startIndex
        let endPosition = characterView.endIndex
        var currentPosition = endPosition

        while currentPosition > startPos {
            let previousPosition = characterView.index(before: currentPosition)
            if characterView[previousPosition] == "/" {
                break
            }
            currentPosition = previousPosition
        }

        return currentPosition
    }
}
