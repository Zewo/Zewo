public struct BasicRouter {
    public let middleware: [Middleware]
    public let routes: [Route]
    public let fallback: Responder
    public let matcher: TrieRouteMatcher

    public init(middleware: [Middleware], routes: [Route], fallback: Responder) {
        self.middleware = middleware
        self.routes = routes
        self.fallback = fallback
        self.matcher = TrieRouteMatcher(routes: routes)
    }

    public init(middleware: [Middleware], routes: Routes) {
        self.init(
            middleware: middleware,
            routes: routes.routes,
            fallback: routes.fallback
        )
    }

    public init(staticFilesPath: String = "Public", middleware: [Middleware] = [], routes: (Routes) -> Void) {
        let r = Routes(staticFilesPath: staticFilesPath)
        routes(r)
        self.init(
            middleware: middleware,
            routes: r.routes,
            fallback: r.fallback
        )
    }
}

public protocol RouterRepresentable : ResponderRepresentable {
    var router: BasicRouter { get }
}

extension RouterRepresentable {
    public var responder: Responder {
        return router
    }
}

extension BasicRouter : Responder {
    public func respond(to request: Request) throws -> Response {
        let responder = matcher.match(request) ?? fallback
        return try middleware.chain(to: responder).respond(to: request)
    }
}

extension BasicRouter : RouterRepresentable {
    public var router: BasicRouter {
        return self
    }
}

extension BasicRouter : ResponderRepresentable {
    public var responder: Responder {
        return self
    }
}
