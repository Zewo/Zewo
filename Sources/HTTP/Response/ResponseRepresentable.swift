import Content

public protocol ResponseRepresentable {
    var response: Response { get }
}

extension JSONError : ResponseRepresentable {
    public var response: Response {
        return Response(status: .badRequest, content: PlainText(description))
    }
}

extension ParametersError : ResponseRepresentable {
    public var response: Response {
        return Response(status: .badRequest, content: PlainText(description))
    }
}
