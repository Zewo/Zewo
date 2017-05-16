import Core

public protocol ResponseRepresentable {
    var response: Response { get }
}

extension Response : ResponseRepresentable {
    public var response: Response {
        return self
    }
}

extension Content : ResponseRepresentable {
    public var response: Response {
        return Response(status: .ok, content: self)
    }
}

extension NoContent : ResponseRepresentable {
    public var response: Response {
        return Response(status: .noContent)
    }
}

extension ContentError : ResponseRepresentable {
    public var response: Response {
        return Response(status: .badRequest, body: description, timeout: 1.minute)
    }
}

extension ParametersError : ResponseRepresentable {
    public var response: Response {
        switch self {
        case .parameterNotFound:
            return Response(status: .badRequest)
        case .cannotInitializeParameter:
            return Response(status: .badRequest)
        case .cannotInitializeParameters:
            return Response(status: .badRequest)
        }
    }
}
