public protocol XMLNode {
    var xmlNode: XML.Node { get }
}

extension XML.Element : XMLNode {
    public var xmlNode: XML.Node {
        return .element(self)
    }
}

extension String : XMLNode {
    public var xmlNode: XML.Node {
        return .content(self)
    }
}

public struct XML {
    public enum Node {
        case element(XML.Element)
        case content(String)
    }
    
    public struct Element {
        public let name: String
        public let attributes: [String: String]
        public internal(set) var children: [Node]
        
        public init(name: String, attributes: [String: String] = [:], children: [XMLNode] = []) {
            self.name = name
            self.attributes = attributes
            self.children = children.map({ $0.xmlNode })
        }
        
        public func attribute(named name: String) throws -> String {
            guard let attribute = attributes[name] else {
                throw DecodingError.keyNotFound(name, DecodingError.Context())
            }
            
            return attribute
        }
        
        public var contents: String {
            var string = ""
            
            for child in children {
                if case let .content(content) = child {
                    string += content.description
                }
            }
            
            return string
        }
        
        public func elements(named name: String) -> [Element] {
            var elements: [Element] = []
            
            for element in self.elements where element.name == name {
                elements.append(element)
            }
            
            return elements
        }
        
        public var elements: [Element] {
            var elements: [Element] = []
            
            for child in children {
                if case let .element(element) = child {
                    elements.append(element)
                }
            }
            
            return elements
        }
        
        public mutating func add(element: Element) {
            children.append(.element(element))
        }
        
        public mutating func add(content: String) {
            children.append(.content(content))
        }
    }
    
    public let root: Element
    
    public init(root: Element) {
        self.root = root
    }
}

extension XML.Element : CustomStringConvertible {
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
        
        return "<\(name)\(attributes)>\(contents)</\(name)>"
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
