import struct Foundation.Data
import struct Foundation.UUID

public protocol JSONInitializable {
    init(json: JSON) throws
}

public protocol JSONRepresentable {
    func json() -> JSON
}

public protocol JSONConvertible : ContentConvertible, JSONInitializable, JSONRepresentable {}

extension JSONConvertible {
    static var contentTypes: ContentTypes<Self> {
        return [ContentType(Self.init(json:), Self.json)]
    }
}

extension JSON : JSONInitializable, JSONRepresentable {
    public init(json: JSON) throws {
        self = json
    }
    
    public func json() -> JSON {
        return self
    }
}

extension Int : JSONInitializable, JSONRepresentable {
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

extension Bool : JSONInitializable, JSONRepresentable {
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

extension String : JSONInitializable, JSONRepresentable {
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

extension Double : JSONInitializable, JSONRepresentable {
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

extension UUID : JSONInitializable, JSONRepresentable {
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
