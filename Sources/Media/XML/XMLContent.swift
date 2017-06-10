import Venice
import Core

extension XML : Content {
    public static var mediaType: MediaType = .xml
    
    public static func parse(from readable: Readable, deadline: Deadline) throws -> XML {
        return try XMLParser.parse(readable, bufferSize: 4096, deadline: deadline)
    }
    
    public func serialize(to writable: Writable, deadline: Deadline) throws {
        // TODO: Improve this
        try writable.write(description, deadline: deadline)
    }
}

// TODO: Implement this in XMLRepresentable
extension XML {
    public static var supportedTypes: [Content.Type] {
        return [XML.self]
    }
    
    public var content: Content {
        return self
    }
    
    public func content(for mediaType: MediaType) throws -> Content {
        guard PlainText.mediaType.matches(other: mediaType) else {
            throw ContentError.unsupportedType
        }
        
        return self
    }
}
