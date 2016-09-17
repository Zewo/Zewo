public class LogMiddleware : Middleware {
    private let debug: Bool
    public var message: String = ""

    public init(debug: Bool = false) {
        self.debug = debug
    }

    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)
        message = "================================================================================\n"
        message += "Request:\n\n"
        message += (debug ? String(describing: request.debugDescription) : String(describing: request)) + "\n"
        message += "--------------------------------------------------------------------------------\n"
        message += "Response:\n\n"
        message += (debug ? String(describing: response.debugDescription) : String(describing: response)) + "\n"
        message += "================================================================================\n"
        print(message)
        return response
    }
}
