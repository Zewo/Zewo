import Foundation

extension Character {
    public var isASCII: Bool {
        return unicodeScalars.reduce(true, { $0 && $1.isASCII })
    }
    
    public var isAlphabetic: Bool {
        return isLowercase || isUppercase
    }
    
    public var isLowercase: Bool {
        return ("a" ... "z").contains(self)
    }
    
    public var isUppercase: Bool {
        return ("A" ... "Z").contains(self)
    }
    
    public var isDigit: Bool {
        return ("0" ... "9").contains(self)
    }
}

extension String {
    public func uppercasedFirstCharacter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
}

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
    
    public func camelCaseSplit() -> [String] {
        var entries: [String] = []
        var runes: [[Character]] = []
        var lastClass = 0
        var currentClass = 0
        
        for character in self {
            switch true {
            case character.isLowercase:
                currentClass = 1
            case character.isUppercase:
                currentClass = 2
            case character.isDigit:
                currentClass = 3
            default:
                currentClass = 4
            }
            
            if currentClass == lastClass {
                var rune = runes[runes.count - 1]
                rune.append(character)
                runes[runes.count - 1] = rune
            } else {
                runes.append([character])
            }
            
            lastClass = currentClass
        }
        
        // handle upper case -> lower case sequences, e.g.
        // "PDFL", "oader" -> "PDF", "Loader"
        if runes.count >= 2 {
            for i in 0 ..< runes.count - 1 {
                if runes[i][0].isUppercase && runes[i + 1][0].isLowercase {
                    runes[i + 1] = [runes[i][runes[i].count - 1]] + runes[i + 1]
                    runes[i] = Array(runes[i][..<(runes[i].count - 1)])
                }
            }
        }
        
        for rune in runes where rune.count > 0 {
            entries.append(String(rune))
        }
        
        return entries
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

