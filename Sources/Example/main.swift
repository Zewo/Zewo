import HTTP

struct Root : Route {
    func get(request: Request) throws -> Response {
        return Response(status: .ok)
    }
}

let root = Root()
let router = Router(route: root)
let server = Server(router: router)

try server.start()
