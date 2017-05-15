import Foundation

public enum ContentError : Error {
    case cannotInitialize(type: ContentInitializable.Type, from: Content)
    case outOfBounds(indexPath: [IndexPathComponent], count: Int)
    case valueNotFound(indexPath: [IndexPathComponent])
    case valueNotArray(indexPath: [IndexPathComponent])
    case valueNotDictionary(indexPath: [IndexPathComponent])
}

public enum Content {
    case null
    case bool(Bool)
    case double(Double)
    case int(Int)
    case string(String)
    case data(Data)
    case array([Content])
    case dictionary([String: Content])
}

extension Content {
    /// :nodoc:
    public init<T: ContentRepresentable>(_ value: T?) throws {
        self = try value?.content() ?? .null
    }
    
    /// :nodoc:
    public init<T: ContentRepresentable>(_ values: [T]?) throws {
        if let values = values {
            self = try .array(values.map({ try $0.content() }))
        } else {
            self = .null
        }
    }
    
    /// :nodoc:
    public init<T: ContentRepresentable>(_ values: [T?]?) throws {
        if let values = values {
            self = try .array(values.map({ try $0?.content() ?? .null}))
        } else {
            self = .null
        }
    }
    
    /// :nodoc:
    public init<T: ContentRepresentable>(_ values: [String: T]?) throws {
        if let values = values {
            var dictionary: [String: Content] = [:]
            
            for (key, value) in try values.map({($0.key, try $0.value.content() )}) {
                dictionary[key] = value
            }
            
            self = .dictionary(dictionary)
        } else {
            self = .null
        }
    }
    
    /// :nodoc:
    public init<T: ContentRepresentable>(_ values: [String: T?]?) throws {
        if let values = values {
            var dictionary: [String: Content] = [:]
            
            for (key, value) in try values.map({($0.key, try $0.value?.content() ?? .null)}) {
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

extension Content {
    public func get<T : ContentInitializable>(_ indexPath: IndexPathComponent...) throws -> T {
        let content = try get(indexPath)
        return try T(content: content)
    }
    
    public func get(_ indexPath: IndexPathComponent...) throws -> Content {
        return try get(indexPath)
    }
    
    private func get(_ indexPath: [IndexPathComponent]) throws -> Content {
        var value = self
        var visited: [IndexPathComponent] = []
        
        for component in indexPath {
            visited.append(component)
            
            switch component.indexPathComponent {
            case let .index(index):
                guard case let .array(array) = self else {
                    throw ContentError.valueNotArray(indexPath: visited)
                }
                
                guard array.indices.contains(index) else {
                    throw ContentError.outOfBounds(indexPath: visited, count: array.count)
                }
                
                value = array[index]
            case let .key(key):
                guard case let .dictionary(dictionary) = self else {
                    throw ContentError.valueNotDictionary(indexPath: visited)
                }
                
                guard let newValue = dictionary[key] else {
                    throw ContentError.valueNotFound(indexPath: visited)
                }
                
                value = newValue
            }
        }
        
        return value
    }
}

extension Content : Equatable {
    /// :nodoc:
    public static func == (lhs: Content, rhs: Content) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null): return true
        case let (.int(l), .int(r)) where l == r: return true
        case let (.bool(l), .bool(r)) where l == r: return true
        case let (.string(l), .string(r)) where l == r: return true
        case let (.data(l), .data(r)) where l == r: return true
        case let (.double(l), .double(r)) where l == r: return true
        case let (.array(l), .array(r)) where l == r: return true
        case let (.dictionary(l), .dictionary(r)) where l == r: return true
        default: return false
        }
    }
}

extension Content : ExpressibleByNilLiteral {
    /// :nodoc:
    public init(nilLiteral value: Void) {
        self = .null
    }
}

extension Content : ExpressibleByBooleanLiteral {
    /// :nodoc:
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension Content : ExpressibleByIntegerLiteral {
    /// :nodoc:
    public init(integerLiteral value: IntegerLiteralType) {
        self = .int(value)
    }
}

extension Content : ExpressibleByFloatLiteral {
    /// :nodoc:
    public init(floatLiteral value: FloatLiteralType) {
        self = .double(value)
    }
}

extension Content : ExpressibleByStringLiteral {
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

extension Content : ExpressibleByArrayLiteral {
    /// :nodoc:
    public init(arrayLiteral elements: Content...) {
        self = .array(elements)
    }
}

extension Content : ExpressibleByDictionaryLiteral {
    /// :nodoc:
    public init(dictionaryLiteral elements: (String, Content)...) {
        var dictionary = [String: Content](minimumCapacity: elements.count)
        
        for (key, value) in elements {
            dictionary[key] = value
        }
        
        self = .dictionary(dictionary)
    }
}

extension Content : CustomStringConvertible {
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
        
        func serialize(content: Content) -> String {
            switch content {
            case .null: return "null"
            case .bool(let bool): return String(bool)
            case .double(let number): return String(number)
            case .int(let number): return String(number)
            case .string(let string): return escape(string)
            case .data(let data): return "b64:" + data.base64EncodedString()
            case .array(let array): return serialize(array: array)
            case .dictionary(let dictionary): return serialize(dictionary: dictionary)
            }
        }
        
        func serialize(array: [Content]) -> String {
            var string = "["
            
            for index in 0 ..< array.count {
                string += serialize(content: array[index])
                
                if index != array.count - 1 {
                    string += ","
                }
            }
            
            return string + "]"
        }
        
        func serialize(dictionary: [String: Content]) -> String {
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
