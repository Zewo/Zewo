import struct Foundation.Data
import struct Foundation.UUID

public protocol JSONInitializable {
    init(json: JSON) throws
}

public protocol JSONRepresentable  {
    func json() -> JSON
}

public protocol JSONConvertible : JSONInitializable, JSONRepresentable {}

extension JSON : JSONConvertible {
    public init(json: JSON) throws {
        self = json
    }
    
    public func json() -> JSON {
        return self
    }
}

extension Int : JSONConvertible {
    public init(json: JSON) throws {
        guard case let .int(value) = json else {
            throw JSONError.cannotInitialize(type: type(of: self), json: json)
        }
        
        self = value
    }
    
    public func json() -> JSON {
        return .int(self)
    }
}

extension Bool : JSONConvertible {
    public init(json: JSON) throws {
        guard case let .bool(value) = json else {
            throw JSONError.cannotInitialize(type: type(of: self), json: json)
        }
        
        self = value
    }
    
    public func json() -> JSON {
        return .bool(self)
    }
}

extension String : JSONConvertible {
    public init(json: JSON) throws {
        guard case let .string(value) = json else {
            throw JSONError.cannotInitialize(type: type(of: self), json: json)
        }
        
        self = value
    }
    
    public func json() -> JSON {
        return .string(self)
    }
}

extension Double : JSONConvertible {
    public init(json: JSON) throws {
        guard case let .double(value) = json else {
            throw JSONError.cannotInitialize(type: type(of: self), json: json)
        }
        
        self = value
    }
    
    public func json() -> JSON {
        return .double(self)
    }
}

extension UUID : JSONConvertible {
    public init(json: JSON) throws {
        guard case let .string(value) = json, let uuid = UUID(uuidString: value) else {
            throw JSONError.cannotInitialize(type: type(of: self), json: json)
        }
        
        self = uuid
    }
    
    public func json() -> JSON {
        return .string(uuidString)
    }
}

// TODO: Implement this with conditional conformance when Swift provides it.
extension Array : JSONInitializable {
    public init(json: JSON) throws {
        guard case let .array(array) = json else {
            throw JSONError.cannotInitialize(type: type(of: self), json: json)
        }
        
        guard let initializable = Element.self as? JSONInitializable.Type else {
            throw JSONError.cannotInitialize(type: type(of: self), json: json)
        }
        
        var this = Array()
        this.reserveCapacity(array.count)
        
        for element in array {
            if let value = try initializable.init(json: element) as? Element {
                this.append(value)
            }
        }
        
        self = this
    }
}

protocol MapDictionaryKeyInitializable {
    init(mapDictionaryKey: String)
}

extension String : MapDictionaryKeyInitializable {
    init(mapDictionaryKey: String) {
        self = mapDictionaryKey
    }
}

extension Dictionary : JSONInitializable {
    public init(json: JSON) throws {
        guard case .object(let object) = json else {
            throw JSONError.cannotInitialize(type: type(of: self), json: json)
        }
        
        guard let keyInitializable = Key.self as? MapDictionaryKeyInitializable.Type else {
            throw JSONError.cannotInitialize(type: type(of: self), json: json)
        }
        
        guard let valueInitializable = Value.self as? JSONInitializable.Type else {
            throw JSONError.cannotInitialize(type: type(of: self), json: json)
        }
        
        var this = Dictionary(minimumCapacity: object.count)
        
        for (key, value) in object {
            if let key = keyInitializable.init(mapDictionaryKey: key) as? Key {
                this[key] = try valueInitializable.init(json: value) as? Value
            }
        }
        
        self = this
    }
}
