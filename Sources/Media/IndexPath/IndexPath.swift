public enum IndexPathComponent {
    /// Index component.
    case index(Int)
    /// Key component.
    case key(String)
}

extension IndexPathComponent : ExpressibleByIntegerLiteral {
    /// :nodoc:
    public init(integerLiteral value: Int) {
        self = .index(value)
    }
}

extension IndexPathComponent : ExpressibleByStringLiteral {
    /// :nodoc:
    public init(unicodeScalarLiteral value: String) {
        self = .key(value)
    }
    
    /// :nodoc:
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .key(value)
    }
    
    /// :nodoc:
    public init(stringLiteral value: StringLiteralType) {
        self = .key(value)
    }
}

extension IndexPathComponent : CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        switch self {
        case let .index(index):
            return index.description
        case let .key(key):
            return key
        }
    }
}

extension Array where Element == IndexPathComponent {
    /// :nodoc:
    public var string: String {
        return map({ $0.description }).joined(separator: ".")
    }
}
