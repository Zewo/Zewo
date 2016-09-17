public enum ReflectionError : Error, CustomStringConvertible {
    case notStruct(type: Any.Type)
    case valueIsNotType(value: Any, type: Any.Type)
    case instanceHasNoKey(type: Any.Type, key: String)
    case requiredValueMissing(key: String)
    case unexpected

    public var description: String {
        return "Reflection Error: \(caseDescription)"
    }

    var caseDescription: String {
        switch self {
        case .notStruct(type: let type): return "\(type) is not a struct"
        case .valueIsNotType(value: let value, type: let type): return "Cannot set value of type \(type(of: value)) as \(type)"
        case .instanceHasNoKey(type: let type, key: let key): return "Instance of type \(type) has no key \(key)"
        case .requiredValueMissing(key: let key): return "No value found for required key \"\(key)\" in dictionary"
        case .unexpected: return "An unexpected error hass occured"
        }
    }
}
