import Foundation

public enum JSON {
    case null
    case bool(Bool)
    case double(Double)
    case int(Int)
    case string(String)
    case array([JSON])
    case object([String: JSON])
}

extension JSON {
    public static var mediaType: MediaType = .json
}

extension JSON {
    public subscript(str: String) -> JSON? {
        get {
            switch self {
            case .object(let dictionary):
                return dictionary[str]
            default:
                return nil
            }
        }
    }
    
    public subscript(_ int: Int) -> JSON? {
        get {
            switch self {
            case .array(let elements):
                return elements[int]
            default:
                return nil
            }
        }
    }
}

extension JSON {
    public var isNull: Bool {
        if case .null = self {
            return true
        }
        
        return false
    }
    
    public var isBool: Bool {
        if case .bool = self {
            return true
        }
        
        return false
    }
    
    public var isNumber: Bool {
        return isDouble || isInt
    }
    
    public var isDouble: Bool {
        if case .double = self {
            return true
        }
        
        return false
    }
    
    public var isInt: Bool {
        if case .int = self {
            return true
        }
        
        return false
    }
    
    public var isString: Bool {
        if case .string = self {
            return true
        }
        
        return false
    }
    
    public var isArray: Bool {
        if case .array = self {
            return true
        }
        
        return false
    }
    
    public var isObject: Bool {
        if case .object = self {
            return true
        }
        
        return false
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
        case let (.object(l), .object(r)) where l == r: return true
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
    public init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
    
    public init(arrayLiteral elements: [JSON]) {
        self = .array(elements)
    }
}

extension JSON : ExpressibleByDictionaryLiteral {
    /// :nodoc:
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var dictionary = [String: JSON](minimumCapacity: elements.count)
        
        for (key, value) in elements {
            dictionary[key] = value
        }
        
        self = .object(dictionary)
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
            case .object(let dictionary): return serialize(dictionary: dictionary)
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
