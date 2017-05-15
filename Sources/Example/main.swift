import HTTP

struct Root : Route {
    func get(request: Request) throws -> Response {
        return Response(status: .ok)
    }
}

let root = Root()
let router = Router(route: root)
let server = Server(respond: router.respond)

try server.start()
