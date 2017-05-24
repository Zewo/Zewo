import struct Foundation.Data
import struct Foundation.UUID

public protocol JSONInitializable {
    init(content: JSON) throws
}

public protocol JSONRepresentable {
    var content: JSON { get }
}

public protocol JSONConvertible : JSONInitializable, JSONRepresentable {}

extension JSON : JSONConvertible {
    public var content: JSON {
        return self
    }
    
    public init(content: JSON) throws {
        self = content
    }
}

extension Int : JSONConvertible {
    public var content: JSON {
        return .int(self)
    }
    
    public init(content: JSON) throws {
        guard case let .int(value) = content else {
            throw JSONError.cannotInitialize(type: type(of: self), content: content)
        }
        
        self = value
    }
}

extension Bool : JSONConvertible {
    public var content: JSON {
        return .bool(self)
    }
    
    public init(content: JSON) throws {
        guard case let .bool(value) = content else {
            throw JSONError.cannotInitialize(type: type(of: self), content: content)
        }
        
        self = value
    }
}

extension String : JSONConvertible {
    public var content: JSON {
        return .string(self)
    }
    
    public init(content: JSON) throws {
        guard case let .string(value) = content else {
            throw JSONError.cannotInitialize(type: type(of: self), content: content)
        }
        
        self = value
    }
}

extension Double : JSONConvertible {
    public var content: JSON {
        return .double(self)
    }
    
    public init(content: JSON) throws {
        guard case let .double(value) = content else {
            throw JSONError.cannotInitialize(type: type(of: self), content: content)
        }
        
        self = value
    }
}

extension UUID : JSONConvertible {
    public var content: JSON {
        return .string(uuidString)
    }
    
    public init(content: JSON) throws {
        guard case let .string(value) = content, let uuid = UUID(uuidString: value) else {
            throw JSONError.cannotInitialize(type: type(of: self), content: content)
        }
        
        self = uuid
    }
}
