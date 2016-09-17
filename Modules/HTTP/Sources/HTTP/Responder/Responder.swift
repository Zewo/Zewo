public protocol Responder : ResponderRepresentable {
    func respond(to request: Request) throws -> Response
}

extension Responder {
    public func respond(to request: Request, result: ((Void) throws -> Response) -> Void) {
        result { try self.respond(to: request) }
    }
}

extension Responder {
    public var responder: Responder {
        return self
    }
}

public protocol ResponderRepresentable {
    var responder: Responder { get }
}

public typealias Respond = (_ to: Request) throws -> Response

public struct BasicResponder : Responder {
    let respond: Respond

    public init(_ respond: @escaping Respond) {
        self.respond = respond
    }

    public func respond(to request: Request) throws -> Response {
        return try self.respond(request)
    }
}
