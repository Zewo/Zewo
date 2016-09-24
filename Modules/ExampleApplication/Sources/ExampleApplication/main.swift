import HTTPServer
let responder = BasicResponder { _ in Response() }
let server = try Server(port: 8080, responder: responder)
try server.start()
