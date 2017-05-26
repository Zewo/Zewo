import struct Foundation.Data
import struct Foundation.UUID

public protocol JSONInitializable : ContentConvertible {
    init(json: JSON) throws
}

extension JSONInitializable {
    public static var contentTypes: ContentTypes<Self> {
        return [
            ContentType(Self.init(json:))
        ]
    }
}

public protocol JSONRepresentable : ContentConvertible {
    func json() -> JSON
}

extension JSONRepresentable {
    public static var contentTypes: ContentTypes<Self> {
        return [
            ContentType(Self.json)
        ]
    }
}

public protocol JSONConvertible : JSONInitializable, JSONRepresentable {}

extension JSONConvertible {
    public static var contentTypes: ContentTypes<Self> {
        return [
            ContentType(Self.init(json:), Self.json)
        ]
    }
}

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
