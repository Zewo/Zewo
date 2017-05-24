import Foundation

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

