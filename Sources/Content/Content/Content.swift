import Venice
import Core

// TODO: Improve this
public enum ContentError : Error {
    case unsupportedType
}

public protocol Content : ContentRepresentable {
    static var mediaType: MediaType { get }
    static func parse(from readable: Readable, deadline: Deadline) throws -> Self
    func serialize(to writable: Writable, deadline: Deadline) throws
}

extension Content {    
    public static func parse(_ buffer: UnsafeRawBufferPointer, deadline: Deadline) throws -> Self {
        let readable = ReadableBuffer(buffer)
        return try parse(from: readable, deadline: deadline)
    }
}

public protocol ContentInitializable {
    static var supportedTypes: [Content.Type] { get }
    init(content: Content) throws
}

public protocol ContentRepresentable {
    static var supportedTypes: [Content.Type] { get }
    var content: Content { get }
    func content(for mediaType: MediaType) throws -> Content
}
