import Venice
import Core
import struct Foundation.Data

public struct PlainText {
    public let description: String
    
    public init(_ description: String) {
        self.description = description
    }
}

public protocol PlainTextInitializable : ContentInitializable {
    init(plainText: PlainText) throws
}

extension PlainTextInitializable {
    public init(content: Content) throws {
        guard let plainText = content as? PlainText else {
            throw JSONError.outOfBounds(indexPath: [], content: "")
        }
        
        try self.init(content: plainText)
    }
}

public protocol PlainTextRepresentable : ContentRepresentable {
    var plainText: PlainText { get }
}

extension PlainTextRepresentable {
    public var content: Content {
        return plainText
    }
}

extension PlainText : PlainTextInitializable {
    public init(plainText: PlainText) throws {
        self = plainText
    }
}

extension PlainText : PlainTextRepresentable {
    public var plainText: PlainText {
        return self
    }
}

extension PlainText : CustomStringConvertible {}

extension PlainText : Content {
    public static var mediaType: MediaType = .plainText
    
    public static func parse(from readable: Readable, deadline: Deadline) throws -> PlainText {
        var bytes: [UInt8] = []
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 2048)
        
        defer {
            buffer.deallocate()
        }
        
        while true {
            let read = try readable.read(buffer, deadline: deadline)
            
            guard !read.isEmpty else {
                break
            }
            
            bytes.append(contentsOf: read)
        }
        
        bytes += [0]
        return PlainText(String(cString: bytes))
    }
    
    public func serialize(to writable: Writable, deadline: Deadline) throws {
        try writable.write(description, deadline: deadline)
    }
}
