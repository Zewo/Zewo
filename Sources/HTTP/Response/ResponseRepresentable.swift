import Core

public protocol ResponseRepresentable {
    var response: Response { get }
}

extension ContentError : ResponseRepresentable {
    public var response: Response {
        return Response(status: .badRequest, body: description, timeout: 5.minutes)
    }
}

extension ParametersError : ResponseRepresentable {
    public var response: Response {
        return Response(status: .badRequest, body: description, timeout: 5.minutes)
    }
}
