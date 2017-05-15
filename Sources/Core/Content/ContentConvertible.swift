import struct Foundation.Data

public protocol ContentInitializable {
    init(content: Content) throws
}

public protocol ContentRepresentable {
    func content() throws -> Content
}

public protocol ContentConvertible : ContentInitializable, ContentRepresentable {}

extension Content : ContentConvertible {
    public func content() throws -> Content {
        return self
    }
    
    public init(content: Content) throws {
        self = content
    }
}

extension Int : ContentConvertible {
    public func content() throws -> Content {
        return .int(self)
    }
    
    public init(content: Content) throws {
        guard case let .int(value) = content else {
            throw ContentError.cannotInitialize(type: type(of: self), from: content)
        }
        
        self = value
    }
}

extension Bool : ContentConvertible {
    public func content() throws -> Content {
        return .bool(self)
    }
    
    public init(content: Content) throws {
        guard case let .bool(value) = content else {
            throw ContentError.cannotInitialize(type: type(of: self), from: content)
        }
        
        self = value
    }
}

extension String : ContentConvertible {
    public func content() throws -> Content {
        return .string(self)
    }
    
    public init(content: Content) throws {
        guard case let .string(value) = content else {
            throw ContentError.cannotInitialize(type: type(of: self), from: content)
        }
        
        self = value
    }
}

extension Double : ContentConvertible {
    public func content() throws -> Content {
        return .double(self)
    }
    
    public init(content: Content) throws {
        guard case let .double(value) = content else {
            throw ContentError.cannotInitialize(type: type(of: self), from: content)
        }
        
        self = value
    }
}

extension Data : ContentConvertible {
    public func content() throws -> Content {
        return .data(self)
    }
    
    public init(content: Content) throws {
        guard case let .data(value) = content else {
            throw ContentError.cannotInitialize(type: type(of: self), from: content)
        }
        
        self = value
    }
}
