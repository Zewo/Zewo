import HTTP

let router = Router { root in
    root.get { request in
        return Response(status: .ok)
    }
}

let server = Server(router: router)
try server.start()
