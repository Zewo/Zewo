public final class Route : Responder {
    public let path: String
    public let middleware: [Middleware]
    public var actions: [Request.Method: Responder]
    public var fallback: Responder

    public init(path: String, middleware: [Middleware] = [], actions: [Request.Method: Responder] = [:], fallback: Responder = Route.defaultFallback) {
        self.path = path
        self.middleware = middleware
        self.actions = actions
        self.fallback = fallback
    }

    public func addAction(method: Request.Method, action: Responder) {
        actions[method] = action
    }

    public static let defaultFallback = BasicResponder { _ in
        throw HTTPError.methodNotAllowed
    }

    public func respond(to request: Request) throws -> Response {
        let action = actions[request.method] ?? fallback
        return try middleware.chain(to: action).respond(to: request)
    }
}

extension Route : CustomStringConvertible {
    public var description: String {
        var actions: [String] = []

        for (method, _) in self.actions {
            actions.append("\(method) \(path)")
        }

        return actions.joined(separator: ", ")
    }
}
