public enum XMLError : Error {
    case noContent(type: XMLInitializable.Type)
    case cannotInitialize(type: XMLInitializable.Type, xml: XML)
    case valueNotArray(indexPath: [IndexPathComponent], xml: XML)
    case outOfBounds(indexPath: [IndexPathComponent], xml: XML)
    case valueNotDictionary(indexPath: [IndexPathComponent], xml: XML)
    case valueNotFound(indexPath: [IndexPathComponent], xml: XML)
}

extension XMLError : CustomStringConvertible {
    public var description: String {
        switch self {
        case let .noContent(type):
            return "Cannot initialize type \"\(String(describing: type))\" with no content."
        case let .cannotInitialize(type, xml):
            return "Cannot initialize type \"\(String(describing: type))\" with xml \(xml)."
        case let .valueNotArray(indexPath, content):
            return "Cannot get xml element for index path \"\(indexPath.string)\". Element is not an array \(content)."
        case let .outOfBounds(indexPath, content):
            return "Cannot get xml element for index path \"\(indexPath.string)\". Index is out of bounds for element \(content)."
        case let .valueNotDictionary(indexPath, content):
            return "Cannot get xml element for index path \"\(indexPath.string)\". Element is not a dictionary \(content)."
        case let .valueNotFound(indexPath, content):
            return "Cannot get xml element for index path \"\(indexPath.string)\". Key is not present in element \(content)."
        }
    }
}

extension Array where Element == XML {
    public func withAttribute(_ name: String, equalTo value: String) -> XML? {
        for element in self where (element.getAttribute(name) as String?) == value {
            return element
        }
        
        return nil
    }
}

public protocol XMLNodeRepresentable {
    var xmlNode: XML.Node { get }
}

extension XML : XMLNodeRepresentable {
    public var xmlNode: XML.Node {
        return .element(self)
    }
}

extension String : XMLNodeRepresentable {
    public var xmlNode: XML.Node {
        return .content(self)
    }
}

public final class XML {
    public enum Node {
        case element(XML)
        case content(String)
    }
    
    public let name: String
    public let attributes: [String: String]
    public internal(set) var children: [Node]
    
    init(name: String, attributes: [String: String] = [:], children: [XMLNodeRepresentable] = []) {
        self.name = name
        self.attributes = attributes
        self.children = children.map({ $0.xmlNode })
    }
    
    public func getAttribute(_ name: String) throws -> String {
        guard let attribute = attributes[name] else {
            throw XMLError.valueNotFound(indexPath: [.key(name)], xml: self)
        }
        
        return attribute
    }
    
    public var contents: String {
        var string = ""
        
        var contents: [String] = []
        
        for child in children {
            if case let .content(content) = child {
                contents.append(content.description)
            }
        }
        
        for content in contents {
            string += content
        }
        
        return string
    }
    
    public func get(_ indexPath: IndexPathComponent...) throws -> XML {
        return try _get(indexPath as [IndexPathComponent])
    }
    
    public func get(_ indexPath: IndexPathComponent...) throws -> [XML] {
        return try _get(indexPath as [IndexPathComponent])
    }
    
    internal func _get(_ indexPath: [IndexPathComponent]) throws -> XML {
        let elements: [XML] = try _get(indexPath)
        
        guard elements.count == 1, let element = elements.first else {
            throw XMLError.valueNotFound(
                indexPath: indexPath,
                xml: self
            )
        }
        
        return element
    }
    
    internal func _get(_ indexPath: [IndexPathComponent]) throws -> [XML] {
        var value = [self]
        var single = true
        var visited: [IndexPathComponent] = []
        
        loop: for component in indexPath {
            visited.append(component)
            
            switch component {
            case let .index(index):
                if single, value.count == 1, let element = value.first {
                    guard element.elements.indices.contains(index) else {
                        throw XMLError.outOfBounds(indexPath: visited, xml: self)
                    }
                    
                    value = [element.elements[index]]
                    single = true
                    continue loop
                }
                
                guard value.indices.contains(index) else {
                    throw XMLError.outOfBounds(indexPath: visited, xml: self)
                }
                
                value = [value[index]]
                single = true
            case let .key(key):
                guard value.count == 1, let element = value.first else {
                    // More than one result
                    throw XMLError.valueNotFound(indexPath: visited, xml: self)
                }
            
                value = element.getElements(named: key)
                single = false
            }
        }
        
        return value
    }
    
    func getElements(named name: String) -> [XML] {
        var elements: [XML] = []
        
        for element in self.elements where element.name == name {
            elements.append(element)
        }
        
        return elements
    }
    
    var elements: [XML] {
        var elements: [XML] = []
        
        for child in children {
            if case let .element(element) = child {
                elements.append(element)
            }
        }
        
        return elements
    }
    
    func addElement(_ element: XML) {
        children.append(.element(element))
    }
    
    func addContent(_ content: String) {
        children.append(.content(content))
    }
}

extension XML : CustomStringConvertible {
    public var description: String {
        var attributes = ""

        for (offset: index, element: (key: key, value: value)) in self.attributes.enumerated() {
            if index == 0 {
                attributes += " "
            }
            
            attributes += key
            attributes += "="
            attributes += value
            
            if index < self.attributes.count - 1 {
                attributes += " "
            }
        }
        
        if !children.isEmpty {
            var string = ""
            string += "<"
            string += name
            string += attributes
            string += ">"
            
            for child in children {
                string += child.description
            }
            
            string += "</"
            string += name
            string += ">"
            return string
        }
        
        guard !contents.isEmpty else {
            return "<\(name)\(attributes)/>"
            
        }
        
        return "<\(name)\(attributes)>\(content)</\(name)>"
    }
}

extension XML.Node : CustomStringConvertible {
    public var description: String {
        switch self {
        case let .element(element):
            return element.description
        case let .content(content):
            return content
        }
    }
}
