import HTTP

let router = BasicRouter { root in
    root.get { request in
        return Response(status: .ok)
    }
}

let server = Server(router: router)
try server.start()
