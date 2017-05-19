import Core
import Venice

public typealias Storage = [String: Any]

public protocol Message : class {
    var version: Version { get set }
    var headers: Headers { get set }
    var storage: Storage { get set }
    var body: Body { get set }
}

extension Message {
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
    
    public func getContent(
        _ contentType: ContentType,
        deadline: Deadline = 5.minutes.fromNow()
    ) throws -> Content {
        guard let mediaType = self.contentType else {
            throw RequestContentError.noContentTypeHeader
        }
        
        guard mediaType == contentType.mediaType else {
            throw RequestContentError.unsupportedMediaType
        }
        
        guard let stream = body.readable else {
            throw RequestContentError.noReadableBody
        }
        
        return try contentType.parser.parse(stream, deadline: deadline)
    }
    
    public func getContent<C : ContentInitializable>(
        _ contentType: ContentType,
        deadline: Deadline = 5.minutes.fromNow()
    ) throws -> C {
        let content = try getContent(contentType, deadline: deadline)
        return try C(content: content)
    }
}
