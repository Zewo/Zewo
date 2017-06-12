import Venice
import Core

extension XML {
    public static var mediaType: MediaType = .xml
    
    public static func parse(from readable: Readable, deadline: Deadline) throws -> XML {
        return try XMLParser.parse(readable, bufferSize: 4096, deadline: deadline)
    }
    
    public func serialize(to writable: Writable, deadline: Deadline) throws {
        // TODO: Improve this
        try writable.write(description, deadline: deadline)
    }
}
