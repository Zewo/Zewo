import HTTP

struct RootRoute : Route {
    func get(request: Request) throws -> Response {
        return Response(status: .ok)
    }
}

let root = RootRoute()
let router = Router(route: root)
let server = Server(router: router)

try server.start()
