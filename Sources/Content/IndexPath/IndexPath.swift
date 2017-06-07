public enum IndexPathComponentValue {
    case index(Int)
    case key(String)
}

extension IndexPathComponentValue : CustomStringConvertible {
    public var description: String {
        switch self {
        case let .index(index):
            return index.description
        case let .key(key):
            return key
        }
    }
}

extension Array where Element == IndexPathComponentValue {
    public var string: String {
        return map({ $0.description }).joined(separator: ".")
    }
}

/// Can be represented as `IndexPathValue`.
public protocol IndexPathComponent {
    var indexPathComponent: IndexPathComponentValue { get }
}

extension Int : IndexPathComponent {
    public var indexPathComponent: IndexPathComponentValue {
        return .index(self)
    }
}

extension String : IndexPathComponent {
    public var indexPathComponent: IndexPathComponentValue {
        return .key(self)
    }
}
