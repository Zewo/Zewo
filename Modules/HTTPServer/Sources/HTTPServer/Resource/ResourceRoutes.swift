public final class ResourceRoutes : Routes {}

extension Routes {
    public func compose(_ path: String, middleware: [Middleware] = [], resource: RouterRepresentable) {
        compose(path, middleware: middleware, router: resource)
    }
}

extension ResourceRoutes {
    public func list(
        middleware: [Middleware] = [],
        respond: @escaping (Request) throws -> Response
        ) {
        add(method: .get, middleware: middleware, respond: respond)
    }

    public func create<Content: MapInitializable>(
        middleware: [Middleware] = [],
        respond: @escaping (Request, Content) throws -> Response) {
        add(method: .post, middleware: middleware, respond: respond)
    }

    public func detail<ID: PathParameterConvertible>(
        middleware: [Middleware] = [],
        respond: @escaping (Request, ID) throws -> Response) {
        add(method: .get, path: "/:id", middleware: middleware, respond: respond)
    }

    public func update<ID: PathParameterConvertible, Content: MapInitializable>(
        middleware: [Middleware] = [],
        respond: @escaping (Request, ID, Content) throws -> Response) {
        add(method: .patch, path: "/:id", middleware: middleware, respond: respond)
    }

    public func destroy<ID: PathParameterConvertible>(
        middleware: [Middleware] = [],
        respond: @escaping (Request, ID) throws -> Response) {
        add(method: .delete, path: "/:id", middleware: middleware, respond: respond)
    }
}
