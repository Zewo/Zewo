import Venice
import Core

public enum ContentError : Error {
    case unsupportedType
}

public protocol Content {
    static var mediaType: MediaType { get }
    static func parse(from readable: Readable, deadline: Deadline) throws -> Self
    func serialize(to writable: Writable, deadline: Deadline) throws
}

extension Content {
    public static func parse(_ buffer: UnsafeRawBufferPointer, deadline: Deadline) throws -> Self {
        let readable = BufferReadable(buffer: buffer)
        return try parse(from: readable, deadline: deadline)
    }
}

public protocol ContentConvertible {
    static var contentTypes: ContentTypes<Self> { get }
}

public struct ContentTypes<T> : ExpressibleByArrayLiteral, Sequence {
    var types: [ContentType<T>]
    
    public init(arrayLiteral types: ContentType<T>...) {
        self.types = types
    }
    
    public func makeIterator() ->  IndexingIterator<Array<ContentType<T>>> {
        return types.makeIterator()
    }
    
    public var `default`: ContentType<T>? {
        return types.first
    }
}

public struct ContentType<T> {
    public typealias Initialize<C> = (C) throws -> T
    public typealias Represent<C> = (T) -> (Void) -> C
    public typealias InitializeContent = (Content) throws -> T
    public typealias RepresentContent = (T) -> (Void) -> Content
    
    public let type: Content.Type
    public let mediaType: MediaType
    public let initialize: InitializeContent?
    public let represent: RepresentContent?
    
    public init<C : Content>(
        _ initialize: @escaping Initialize<C>,
        _ represent: @escaping Represent<C>
    ) {
        self.type = C.self
        self.mediaType = type.mediaType
        
        self.initialize = { content in
            guard let content = content as? C else {
                throw ContentError.unsupportedType
            }
            
            return try initialize(content)
        }
        
        self.represent = { represent($0) }
    }
    
    public init<C : Content>(_ initialize: @escaping Initialize<C>) {
        self.type = C.self
        self.mediaType = type.mediaType
        self.represent = nil
        
        self.initialize = { content in
            guard let content = content as? C else {
                throw ContentError.unsupportedType
            }
            
            return try initialize(content)
        }
    }
    
    public init<C : Content>(_ represent: @escaping Represent<C>) {
        self.type = C.self
        self.mediaType = type.mediaType
        self.initialize = nil
        self.represent = { represent($0) }
    }
}
