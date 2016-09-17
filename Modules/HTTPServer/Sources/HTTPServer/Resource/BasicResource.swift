public struct BasicResource {
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

    public init(middleware: [Middleware], routes: ResourceRoutes) {
        self.init(
            middleware: middleware,
            routes: routes.routes,
            fallback: routes.fallback
        )
    }

    public init(staticFilesPath: String = "Public", middleware: [Middleware] = [], routes: (ResourceRoutes) -> Void) {
        let r = ResourceRoutes(staticFilesPath: staticFilesPath)
        routes(r)
        self.init(
            middleware: middleware,
            routes: r.routes,
            fallback: r.fallback
        )
    }
}

extension BasicResource : Responder {
    public func respond(to request: Request) throws -> Response {
        let responder = matcher.match(request) ?? fallback
        return try middleware.chain(to: responder).respond(to: request)
    }
}

extension BasicResource : RouterRepresentable {
    public var router: BasicRouter {
        return BasicRouter(middleware: middleware, routes: routes, fallback: fallback)
    }
}

extension BasicResource : ResponderRepresentable {
    public var responder: Responder {
        return self
    }
}
