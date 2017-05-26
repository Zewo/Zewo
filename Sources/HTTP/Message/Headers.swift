import Core
import Foundation

public struct Headers {
    fileprivate var headers: [Field: String]
    
    public init(_ headers: [Field: String]) {
        self.headers = headers
    }
    
    public var fields: [Field] {
        return Array(headers.keys)
    }
    
    public struct Field {
        public let original: String
        
        public init(_ original: String) {
            self.original = original
        }
    }

}

extension Headers {
    public static var empty: Headers {
        return Headers()
    }
}

extension Headers : ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Field, String)...) {
        var headers: [Field: String] = [:]
        
        for (key, value) in elements {
            headers[key] = value
        }
        
        self.headers = headers
    }
}

extension Headers : Sequence {
    public func makeIterator() -> DictionaryIterator<Field, String> {
        return headers.makeIterator()
    }
    
    public var count: Int {
        return headers.count
    }
    
    public var isEmpty: Bool {
        return headers.isEmpty
    }
    
    public subscript(field: Field) -> String? {
        get {
            return headers[field]
        }
        
        set(header) {
            headers[field] = header
        }
    }
    
    public subscript(field: String) -> String? {
        get {
            return self[Field(field)]
        }
        
        set(header) {
            self[Field(field)] = header
        }
    }
}

extension Headers : CustomStringConvertible {
    public var description: String {
        var string = ""
        
        for (header, value) in headers {
            string += "\(header): \(value)\n"
        }
        
        return string
    }
}

extension Headers : Equatable {
    public static func == (lhs: Headers, rhs: Headers) -> Bool {
        return lhs.headers == rhs.headers
    }
}

extension Headers.Field : Hashable {
    public var hashValue: Int {
        return original.hashValue
    }
    
    public static func == (lhs: Headers.Field, rhs: Headers.Field) -> Bool {
        if lhs.original == rhs.original {
            return true
        }
        
        return lhs.original.caseInsensitiveCompare(rhs.original)
    }
}

extension Headers.Field : ExpressibleByStringLiteral {
    public init(stringLiteral string: String) {
        self.init(string)
    }
    
    public init(extendedGraphemeClusterLiteral string: String){
        self.init(string)
    }
    
    public init(unicodeScalarLiteral string: String){
        self.init(string)
    }
}

extension Headers.Field : CustomStringConvertible {
    public var description: String {
        return original
    }
}

extension UTF8.CodeUnit {
    fileprivate func lowercased() -> UTF8.CodeUnit {
        let isUppercase = self >= 65 && self <= 90
        
        if isUppercase {
            return self + 32
        }
        
        return self
    }
}

extension String {
    fileprivate func caseInsensitiveCompare(_ other: String) -> Bool {
        if self.utf8.count != other.utf8.count {
            return false
        }
        
        for (lhs, rhs) in zip(self.utf8, other.utf8) {
            if lhs.lowercased() != rhs.lowercased() {
                return false
            }
        }
        
        return true
    }
}
