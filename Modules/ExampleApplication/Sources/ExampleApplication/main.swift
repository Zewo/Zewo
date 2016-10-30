import HTTPServer
import HTTPClient

let arguments = try Configuration.commandLineArguments()
let port = arguments["port"].int ?? 8080
let log = LogMiddleware()

let router = BasicRouter { route in
    route.get("/hello") { request in
        return Response(body: "Hello, world!")
    }

    route.get("/orgs/*") { request in
        let client = try Client(url: "https://api.github.com")
        return try client.get(request.path ?? "")
    }
}

let server = try Server(port: port, middleware: [log], responder: router)
try server.start()
