public protocol Router : RouterRepresentable {
    var staticFilesPath: String { get }
    var middleware: [Middleware] { get }

    func recover(error: Error) throws -> Response
    func custom(routes: Routes)
}

extension Router {
    public var staticFilesPath: String {
        return "Public"
    }

    public var middleware: [Middleware] {
        return []
    }

    public func recover(error: Error) throws -> Response {
        return try RecoveryMiddleware.recover(error: error)
    }

    public func custom(routes: Routes) {}
}

extension Router {
    public var router: BasicRouter {
        let routes = Routes(staticFilesPath: staticFilesPath)
        custom(routes: routes)
        return BasicRouter(middleware: [RecoveryMiddleware(recover)] + middleware, routes: routes)
    }
}
