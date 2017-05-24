import Foundation

public enum JSONError : Error {
    case noContent(type: JSONInitializable.Type)
    case cannotInitialize(type: JSONInitializable.Type, content: JSON)
    case valueNotArray(indexPath: [IndexPathComponentValue], content: JSON)
    case outOfBounds(indexPath: [IndexPathComponentValue], content: JSON)
    case valueNotDictionary(indexPath: [IndexPathComponentValue], content: JSON)
    case valueNotFound(indexPath: [IndexPathComponentValue], content: JSON)
}

extension JSONError : CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        switch self {
        case let .noContent(type):
            return "Cannot initialize type \"\(String(describing: type))\" with no content."
        case let .cannotInitialize(type, content):
            return "Cannot initialize type \"\(String(describing: type))\" with content \(content)."
        case let .valueNotArray(indexPath, content):
            return "Cannot get content for index path \"\(indexPath.string)\". Content is not an array \(content)."
        case let .outOfBounds(indexPath, content):
            return "Cannot get content for index path \"\(indexPath.string)\". Index is out of bounds for content \(content)."
        case let .valueNotDictionary(indexPath, content):
            return "Cannot get content for index path \"\(indexPath.string)\". Content is not a dictionary \(content)."
        case let .valueNotFound(indexPath, content):
            return "Cannot get content for index path \"\(indexPath.string)\". Key is not present in content \(content)."
        }
    }
}

public enum JSON {
    case null
    case bool(Bool)
    case double(Double)
    case int(Int)
    case string(String)
    case array([JSON])
    case dictionary([String: JSON])
}

extension JSON {
    /// :nodoc:
    public init<T: JSONRepresentable>(_ value: T?) {
        self = value?.content ?? .null
    }
    
    /// :nodoc:
    public init<T: JSONRepresentable>(_ values: [T]?) {
        if let values = values {
            self = .array(values.map({ $0.content }))
        } else {
            self = .null
        }
    }
    
    /// :nodoc:
    public init<T: JSONRepresentable>(_ values: [T?]?) {
        if let values = values {
            self = .array(values.map({ $0?.content ?? .null}))
        } else {
            self = .null
        }
    }
    
    /// :nodoc:
    public init<T: JSONRepresentable>(_ values: [String: T]?) {
        if let values = values {
            var dictionary: [String: JSON] = [:]
            
            for (key, value) in values.map({($0.key, $0.value.content )}) {
                dictionary[key] = value
            }
            
            self = .dictionary(dictionary)
        } else {
            self = .null
        }
    }
    
    /// :nodoc:
    public init<T: JSONRepresentable>(_ values: [String: T?]?) {
        if let values = values {
            var dictionary: [String: JSON] = [:]
            
            for (key, value) in values.map({($0.key, $0.value?.content ?? .null)}) {
                dictionary[key] = value
            }
            
            self = .dictionary(dictionary)
        } else {
            self = .null
        }
    }
}

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
    fileprivate var string: String {
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

extension JSON {
    public func get<T : JSONInitializable>(_ indexPath: IndexPathComponent...) throws -> T {
        let content = try get(indexPath)
        return try T(content: content)
    }
    
    public func get(_ indexPath: IndexPathComponent...) throws -> JSON {
        return try get(indexPath)
    }
    
    private func get(_ indexPath: [IndexPathComponent]) throws -> JSON {
        var value = self
        var visited: [IndexPathComponentValue] = []
        
        for component in indexPath {
            visited.append(component.indexPathComponent)
            
            switch component.indexPathComponent {
            case let .index(index):
                guard case let .array(array) = value else {
                    throw JSONError.valueNotArray(indexPath: visited, content: self)
                }
                
                guard array.indices.contains(index) else {
                    throw JSONError.outOfBounds(indexPath: visited, content: self)
                }
                
                value = array[index]
            case let .key(key):
                guard case let .dictionary(dictionary) = value else {
                    throw JSONError.valueNotDictionary(indexPath: visited, content: self)
                }
                
                guard let newValue = dictionary[key] else {
                    throw JSONError.valueNotFound(indexPath: visited, content: self)
                }
                
                value = newValue
            }
        }
        
        return value
    }
}

extension JSON : Equatable {
    /// :nodoc:
    public static func == (lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null): return true
        case let (.int(l), .int(r)) where l == r: return true
        case let (.bool(l), .bool(r)) where l == r: return true
        case let (.string(l), .string(r)) where l == r: return true
        case let (.double(l), .double(r)) where l == r: return true
        case let (.array(l), .array(r)) where l == r: return true
        case let (.dictionary(l), .dictionary(r)) where l == r: return true
        default: return false
        }
    }
}

extension JSON : ExpressibleByNilLiteral {
    /// :nodoc:
    public init(nilLiteral value: Void) {
        self = .null
    }
}

extension JSON : ExpressibleByBooleanLiteral {
    /// :nodoc:
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension JSON : ExpressibleByIntegerLiteral {
    /// :nodoc:
    public init(integerLiteral value: IntegerLiteralType) {
        self = .int(value)
    }
}

extension JSON : ExpressibleByFloatLiteral {
    /// :nodoc:
    public init(floatLiteral value: FloatLiteralType) {
        self = .double(value)
    }
}

extension JSON : ExpressibleByStringLiteral {
    /// :nodoc:
    public init(unicodeScalarLiteral value: String) {
        self = .string(value)
    }
    
    /// :nodoc:
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }
    
    /// :nodoc:
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension JSON : ExpressibleByArrayLiteral {
    /// :nodoc:
    public init(arrayLiteral elements: JSONRepresentable...) {
        self = .array(elements.map({ $0.content }))
    }
}

extension JSON : ExpressibleByDictionaryLiteral {
    /// :nodoc:
    public init(dictionaryLiteral elements: (String, JSONRepresentable)...) {
        var dictionary = [String: JSON](minimumCapacity: elements.count)
        
        for (key, value) in elements {
            dictionary[key] = value.content
        }
        
        self = .dictionary(dictionary)
    }
}

extension JSON : CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        let escapeMapping: [UnicodeScalar: String.UnicodeScalarView] = [
            "\r": "\\r".unicodeScalars,
            "\n": "\\n".unicodeScalars,
            "\t": "\\t".unicodeScalars,
            "\\": "\\\\".unicodeScalars,
            "\"": "\\\"".unicodeScalars,
            
            "\u{2028}": "\\u2028".unicodeScalars,
            "\u{2029}": "\\u2029".unicodeScalars,
        ]
        
        func escape(_ source: String) -> String {
            var string: String.UnicodeScalarView = "\"".unicodeScalars
            
            for scalar in source.unicodeScalars {
                if let escaped = escapeMapping[scalar] {
                    string.append(contentsOf: escaped)
                } else {
                    string.append(scalar)
                }
            }
            
            string.append("\"")
            
            return String(string)
        }
        
        func serialize(content: JSON) -> String {
            switch content {
            case .null: return "null"
            case .bool(let bool): return String(bool)
            case .double(let number): return String(number)
            case .int(let number): return String(number)
            case .string(let string): return escape(string)
            case .array(let array): return serialize(array: array)
            case .dictionary(let dictionary): return serialize(dictionary: dictionary)
            }
        }
        
        func serialize(array: [JSON]) -> String {
            var string = "["
            
            for index in 0 ..< array.count {
                string += serialize(content: array[index])
                
                if index != array.count - 1 {
                    string += ","
                }
            }
            
            return string + "]"
        }
        
        func serialize(dictionary: [String: JSON]) -> String {
            var string = "{"
            var index = 0
            
            for (key, value) in dictionary.sorted(by: {$0.0 < $1.0}) {
                string += escape(key) + ":" + serialize(content: value)
                
                if index != dictionary.count - 1 {
                    string += ","
                }
                
                index += 1
            }
            
            return string + "}"
        }
        
        return serialize(content: self)
    }
}
