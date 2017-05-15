import struct Foundation.UUID

public enum ParametersError : Error {
    case parameterNotFound(parameterKey: String)
    case cannotInitializeParameter(type: LosslessStringConvertible.Type, from: String)
    case cannotInitializeParameters(type: ParametersInitializable.Type, from: URI.Parameters)
}

// TODO: Make ParametersError CustomStringConvertible

public protocol ParametersInitializable {
    init(parameters: URI.Parameters) throws
}

extension URI.Parameters {
    public mutating func set(_ parameter: String, for parameterKey: String) {
        parameters[parameterKey] = parameter
    }
    
    public func get<P : LosslessStringConvertible>(_ parameterKey: String) throws -> P {
        guard let string = parameters[parameterKey] else {
            throw ParametersError.parameterNotFound(parameterKey: parameterKey)
        }
        
        guard let parameter = P(string) else {
            throw ParametersError.cannotInitializeParameter(type: P.self, from: string)
        }
        
        return parameter
    }
}

extension Int : LosslessStringConvertible {
    public init?(_ parameter: String) {
        guard let int = Int(parameter) else {
            return nil
        }
        
        self = int
    }
}

extension UUID : LosslessStringConvertible {
    public init?(_ parameter: String) {
        guard let uuid = UUID(uuidString: parameter) else {
            return nil
        }
        
        self = uuid
    }
}
