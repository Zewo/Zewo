public protocol PathParameterConvertible {
    init(pathParameter: String) throws
    var pathParameter: String { get }
}

extension String : PathParameterConvertible {
    public init(pathParameter: String) throws {
        self = pathParameter
    }

    public var pathParameter: String {
        return self
    }
}

extension Int : PathParameterConvertible {
    public init(pathParameter: String) throws {
        guard let int = Int(pathParameter) else {
            throw HTTPError.badRequest
        }
        self.init(int)
    }

    public var pathParameter: String {
        return String(self)
    }
}
