import struct Foundation.UUID

public enum ParametersError : Error {
    case valueNotFound(key: String, parameters: URI.Parameters)
    case cannotInitialize(type: LosslessStringConvertible.Type, parameter: String)
}

extension ParametersError : CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        switch self {
        case let .valueNotFound(key, parameters):
            return "Cannot get parameter for key \"\(key)\". Key is not present in parameters \(parameters)."
        case let .cannotInitialize(type, parameter):
            return "Cannot initialize type \"\(String(describing: type))\" with parameter \"\(parameter)\"."
        }
    }
}

public protocol ParametersInitializable {
    init(parameters: URI.Parameters) throws
}
