import Foundation

public struct Cookie {
    public var name: String
    public var value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

extension Cookie {
    public static func parse(cookieHeader: String) -> Set<Cookie> {
        var cookies: Set<Cookie> = []
        let tokens = cookieHeader.components(separatedBy: ";")
        
        for token in tokens {
            let cookieTokens = token.components(separatedBy: "=")
            
            guard cookieTokens.count == 2 else {
                return []
            }
            
            cookies.insert(Cookie(name: cookieTokens[0].trimmingCharacters(in: .whitespacesAndNewlines), value: cookieTokens[1].trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        
        return cookies
    }
}

extension Cookie : Hashable {
    /// :nodoc:
    public var hashValue: Int {
        return name.hashValue
    }

    /// :nodoc:
    public static func == (lhs: Cookie, rhs: Cookie) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Cookie : CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        return "\(name)=\(value)"
    }
}
