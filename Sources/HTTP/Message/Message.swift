import Core
import Content
import Venice

// TODO: Make error CustomStringConvertible and ResponseRepresentable
public enum MessageError : Error {
    case noReadableBody
    case noContentTypeHeader
    case unsupportedMediaType
    case noDefaultContentType
    case notContentRepresentable
    case valueNotFound(key: String)
    case incompatibleType(requestedType: Any.Type, actualType: Any.Type)
}

public typealias Storage = [String: Any]

public protocol Message : class {
    var version: Version { get set }
    var headers: Headers { get set }
    var storage: Storage { get set }
    var body: Body { get set }
}

extension Message {
    public func set(_ value: Any?, key: String) {
        storage[key] = value
    }
    
    public func get<T>(_ key: String) throws -> T {
        guard let value = storage[key] else  {
            throw MessageError.valueNotFound(key: key)
        }
        
        guard let castedValue = value as? T else {
            throw MessageError.incompatibleType(requestedType: T.self, actualType: type(of: value))
        }
        
        return castedValue
    }
    
    public var contentType: MediaType? {
        get {
            return headers["Content-Type"].flatMap({try? MediaType(string: $0)})
        }
        
        set(contentType) {
            headers["Content-Type"] = contentType?.description
        }
    }
    
    public var contentLength: Int? {
        get {
            return headers["Content-Length"].flatMap({Int($0)})
        }
        
        set(contentLength) {
            headers["Content-Length"] = contentLength?.description
        }
    }
    
    public var transferEncoding: String? {
        get {
            return headers["Transfer-Encoding"]
        }
        
        set(transferEncoding) {
            headers["Transfer-Encoding"] = transferEncoding
        }
    }
    
    public var isChunkEncoded: Bool {
        return transferEncoding == "chunked"
    }

    public var connection: String? {
        return headers["Connection"]
    }

    public var isKeepAlive: Bool {
        if version.minor == 0 {
            return connection?.lowercased() == "keep-alive"
        }

        return connection?.lowercased() != "close"
    }

    public var isUpgrade: Bool {
        return connection?.lowercased() == "upgrade"
    }

    public var upgrade: String? {
        return headers["Upgrade"]
    }
    
    public func content<C : Content>(deadline: Deadline = 5.minutes.fromNow()) throws -> C {
        guard let mediaType = self.contentType else {
            throw MessageError.noContentTypeHeader
        }
        
        guard mediaType == C.mediaType else {
            throw MessageError.unsupportedMediaType
        }
        
        guard let readable = body.readable else {
            throw MessageError.noReadableBody
        }
        
        return try C.parse(from: readable, deadline: deadline)
    }
    
    public func content<C : ContentConvertible>(deadline: Deadline = 5.minutes.fromNow()) throws -> C {
        guard let mediaType = self.contentType else {
            throw MessageError.noContentTypeHeader
        }
        
        guard let readable = body.readable else {
            throw MessageError.noReadableBody
        }
        
        for contentType in C.contentTypes where contentType.mediaType.matches(other: mediaType) {
            let content = try contentType.type.parse(from: readable, deadline: deadline)
            
            guard let initializer = try contentType.initialize?(content) else {
                continue
            }
            
            return initializer
        }
        
        throw MessageError.unsupportedMediaType
    }
}
