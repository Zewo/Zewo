import Foundation

public enum HTTPClientError : Error {
    case invalidURIScheme
    case uriHostRequired
    case brokenConnection
}

public final class Client : Responder {
    fileprivate let secure: Bool

    public let host: String
    public let port: Int

    public let verifyBundle: String?
    public let certificate: String?
    public let privateKey: String?
    public let certificateChain: String?

    public let keepAlive: Bool
    public let connectionTimeout: Double
    public let requestTimeout: Double
    public let bufferSize: Int

    var connection: Connection?
    var serializer: RequestSerializer?
    var parser: ResponseParser?

    public init(url: URL, configuration: Map = nil) throws {
        self.secure = try isSecure(url: url)

        let (host, port) = try getHostPort(url: url)

        self.host = host
        self.port = port

        self.verifyBundle = configuration["tls", "backlog"].string
        self.certificate = configuration["tls", "reusePort"].string
        self.privateKey = configuration["tls", "reusePort"].string
        self.certificateChain = configuration["tls", "reusePort"].string

        self.keepAlive = configuration["keepAlive"].bool ?? true
        self.connectionTimeout = configuration["connectionTimeout"].double ?? 3.minutes
        self.requestTimeout = configuration["requestTimeout"].double ?? 30.seconds

        self.bufferSize = configuration["bufferSize"].int ?? 2048
    }

    public convenience init(url: String, configuration: Map = nil) throws {
        guard let url = URL(string: url) else {
            throw URLError.invalidURL
        }

        try self.init(url: url, configuration: configuration)
    }
}

extension Client {
    public func request(_ request: Request, middleware: [Middleware] = []) throws -> Response {
        var request = request
        addHeaders(to: &request)
        return try middleware.chain(to: self).respond(to: request)
    }

    public func respond(to request: Request) throws -> Response {
        var request = request
        addHeaders(to: &request)

        let connection = try getConnection()
        let serializer = getSerializer(connection: connection)
        let parser = getParser(connection: connection)

        self.connection = connection
        self.serializer = serializer
        self.parser = parser

        let requestDeadline = now() + requestTimeout

        do {
            // TODO: Add deadline to serializer
            try serializer.serialize(request)
            let response = try parser.parse(deadline: requestDeadline)

            if let upgrade = request.upgradeConnection {
                try upgrade(response, connection)
            }

            if response.isError || !keepAlive {
                self.connection = nil
            }

            return response
        } catch let error as StreamError {
            self.connection = nil
            throw error
        }
    }

    private func addHeaders(to request: inout Request) {
        request.host = "\(host):\(port)"
        request.userAgent = "Zewo"

        if !keepAlive && request.connection == nil {
            request.connection = "close"
        }
    }

    private func getConnection() throws -> Connection {
        if let connection = self.connection {
            return connection
        }

        let connection: Connection

        if secure {
            connection = try TCPTLSConnection(
                host: host,
                port: port,
                verifyBundle: verifyBundle,
                certificate: certificate,
                privateKey: privateKey,
                certificateChain: certificateChain,
                sniHostname: host,
                deadline: now() + connectionTimeout
            )
        } else {
            connection = try TCPConnection(
                host: host,
                port: port,
                deadline: now() + connectionTimeout
            )
        }

        try connection.open(deadline: now() + connectionTimeout)
        return connection
    }

    private func getSerializer(connection: Connection) -> RequestSerializer {
        if let serializer = serializer {
            return serializer
        }
        return RequestSerializer(stream: connection)
    }

    private func getParser(connection: Connection) -> ResponseParser {
        if let parser = self.parser {
            return parser
        }
        return ResponseParser(stream: connection, bufferSize: self.bufferSize)
    }
}

//extension Client {
//    public func get(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .get, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    public func head(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .head, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    public func post(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .post, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    public func put(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .put, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    public func patch(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .patch, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    public func delete(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .delete, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    public func options(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .options, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    private func request(method: Request.Method, uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        let req = try Request(method: method, uri: URI(uri), headers: headers, body: body.data)
//        return try request(req, middleware: middleware)
//    }
//}
//
//extension Client {
//    public static func get(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .get, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    public static func head(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .head, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    public static func post(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .post, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    public static func put(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .put, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    public static func patch(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .patch, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    public static func delete(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .delete, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    public static func options(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> Response {
//        return try request(method: .options, uri: uri, headers: headers, body: body, middleware: middleware)
//    }
//
//    fileprivate static func request(method: Request.Method, url: String, headers: Headers = [:], body: DataRepresentable, middleware: [Middleware] = []) throws -> Response {
//        guard let clientURI = URL(string: url) else {
//            throw URLError.invalidURL
//        }
//
//        let client = try getCachedClient(uri: clientURI)
//        let requestURI = URL(path: clientURI.path ?? "/", query: clientURI.query, fragment: clientURI.fragment)
//        let request = Request(method: method, uri: requestURI, headers: headers, body: body.data)
//        return try client.request(request, middleware: middleware)
//    }
//
//    private static func getCachedClient(url: URL) throws -> Client {
//        let (host, port) = try getHostPort(uri: uri)
//        let hash = host.hashValue ^ port.hashValue
//
//        guard let client = cachedClients[hash] else {
//            let client = try Client(uri: uri)
//            cachedClients[hash] = client
//            return client
//        }
//
//        return client
//    }
//}

public class TypedResponse<T : MapInitializable> {
    public let response: Response
    public let content: T

    public init(response: Response) throws {
        guard let content = response.content else {
            throw MapError.incompatibleType
        }
        self.response = response
        self.content = try T(map: content)
    }
}

//extension Client {
//    public static func get<T : MapInitializable>(_ uri: String, headers: Headers = [:], body: DataRepresentable = Data(), middleware: [Middleware] = []) throws -> TypedResponse<T> {
//        let contentNegotiation = ContentNegotiationMiddleware(mediaTypes: [JSON.self], mode: .client)
//        var chain: [Middleware] = [contentNegotiation]
//        chain += middleware
//        let response = try request(method: .get, uri: uri, headers: headers, body: body, middleware: chain)
//        return try TypedResponse(response: response)
//    }
//}

fileprivate func isSecure(url: URL) throws -> Bool {
    let scheme = url.scheme ?? "http"

    switch scheme {
    case "http": return false
    case "https": return true
    default: throw HTTPClientError.invalidURIScheme
    }
}

fileprivate func getHostPort(url: URL) throws -> (String, Int) {
    let scheme = url.scheme ?? "http"

    guard let host = url.host else {
        throw HTTPClientError.uriHostRequired
    }

    let port: Int

    switch scheme {
    case "http": port = url.port ?? 80
    case "https": port = url.port ?? 443
    default: throw HTTPClientError.invalidURIScheme
    }

    return (host, port)
}

private var cachedClients: [Int: Client] = [:]
