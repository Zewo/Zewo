import HTTP

let router = BasicRouter { root in
    root.get { request in
        return Response(status: .ok, headers: ["Transfer-Encoding": "chunked"]) { stream in
            try stream.write("hello world", deadline: 1.second.fromNow())
        }
    }
}

let server = Server(router: router)
try server.start()
