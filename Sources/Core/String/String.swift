import Foundation

extension CharacterSet {
    public static var urlAllowed: CharacterSet {
        let uppercaseAlpha = CharacterSet(charactersIn: "A" ... "Z")
        let lowercaseAlpha = CharacterSet(charactersIn: "a" ... "z")
        let numeric = CharacterSet(charactersIn: "0" ... "9")
        let symbols: CharacterSet = ["_", "-", "~", "."]
        
        return uppercaseAlpha
            .union(lowercaseAlpha)
            .union(numeric)
            .union(symbols)
    }
}

extension String {
    public func trimmed() -> String {
        let regex = try! NSRegularExpression(pattern: "  +", options: .caseInsensitive)
        
        return regex.stringByReplacingMatches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: utf8.count),
            withTemplate: " "
        ).trimmingCharacters(in: .whitespaces)
    }
}

extension Int : LosslessStringConvertible {
    public init?(_ string: String) {
        guard let int = Int(string, radix: 10) else {
            return nil
        }
        
        self = int
    }
}

extension UUID : LosslessStringConvertible {
    public init?(_ string: String) {
        guard let uuid = UUID(uuidString: string) else {
            return nil
        }
        
        self = uuid
    }
}

