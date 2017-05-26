import Foundation

public enum XMLInitializableError: Error, CustomStringConvertible {
    case implementationIsMissing(method: String)
    case nodeIsInvalid(node: XML)
    case nodeHasNoValue
    case typeConversionFailed(type: String, element: XML)
    case attributeDoesNotExist(element: XML, attribute: String)
    case attributeDeserializationFailed(type: String, attribute: String)
    
    public var description: String {
        switch self {
        case let .implementationIsMissing(method):
            return "This deserialization method is not implemented: \(method)"
        case let .nodeIsInvalid(node):
            return "This node is invalid: \(node)"
        case .nodeHasNoValue:
            return "This node is empty"
        case let .typeConversionFailed(type, node):
            return "Can't convert node \(node) to value of type \(type)"
        case let .attributeDoesNotExist(element, attribute):
            return "element \(element) does not contain attribute: \(attribute)"
        case let .attributeDeserializationFailed(type, attribute):
            return "Can't convert attribute \(attribute) to value of type \(type)"
        }
    }
}

public protocol XMLInitializable {
    init(xml: XML) throws
}

public extension XML {
    public func getAttribute<A : LosslessStringConvertible>(_ name: String) throws -> A {
        let attribute = try getAttribute(name)
        
        guard let value = A(attribute) else {
            throw XMLError.attribute(attribute: "")
        }
        
        return value
    }
    
    public func getAttribute<A : LosslessStringConvertible>(_ name: String) -> A? {
        return try? getAttribute(name)
    }
    
    func get<T: XMLInitializable>(_ indexPath: IndexPathComponent...) throws -> T {
        let element: XML = try _get(indexPath as [IndexPathComponent])
        return try T(xml: element)
    }
    
    func get<T: XMLInitializable>(_ indexPath: IndexPathComponent...) -> T? {
        guard let element = try? _get(indexPath as [IndexPathComponent]) as XML else {
            return nil
        }
        
        return try? T(xml: element)
    }
    
    func get<T: XMLInitializable>(_ indexPath: IndexPathComponent...) throws -> [T] {
        return try _get(indexPath as [IndexPathComponent]).map({ try T(xml: $0) })
    }
}

extension String : XMLInitializable {
    public init(xml: XML) throws {
        self = xml.content
    }
}

extension Int : XMLInitializable {
    public init(xml: XML) throws {
        guard let value = Int(xml.content) else {
            throw XMLInitializableError.typeConversionFailed(type: "Int", element: xml)
        }
        
        self = value
    }
}

extension Double : XMLInitializable {
    public init(xml: XML) throws {
        guard let value = Double(xml.content) else {
            throw XMLInitializableError.typeConversionFailed(type: "Double", element: xml)
        }
        
        self = value
    }
}

extension Float : XMLInitializable {
    public init(xml: XML) throws {
        guard let value = Float(xml.content) else {
            throw XMLInitializableError.typeConversionFailed(type: "Float", element: xml)
        }
        
        self = value
    }
}

extension Bool : XMLInitializable {
    public init(xml: XML) throws {
        guard let value = Bool(xml.content) else {
            throw XMLInitializableError.typeConversionFailed(type: "Float", element: xml)
        }
        
        self = value
    }
}
