import Foundation
extension String {
    public init?(json: JSON?) {
        guard let json = json else { return nil}
        switch json {
        case .string(let v):
            self = v
        default:
            return nil
        }
    }
}

extension Double {
    public init?(json: JSON?) {
        guard let json = json else { return nil}
        switch json {
        case .double(let v):
            self = v
        default:
            return nil
        }
    }
}

extension Int {
    public init?(json: JSON?) {
        guard let json = json else { return nil}
        switch json {
        case .int(let v):
            self = v
        default:
            return nil
        }
    }
}


extension Bool {
    public init?(json: JSON?) {
        guard let json = json else { return nil }
        switch json {
        case .bool(let v):
            self = v
        default:
            return nil
        }
    }
}


extension Array where Array.Element == JSON {
    public init?(json: JSON?) {
        guard let json = json else { return nil }
        switch json {
        case .array(let v):
            self = v
        default:
            return nil
        }
    }
}


extension Dictionary where Dictionary.Key == String, Dictionary.Value == JSON {
    public init?(json: JSON?) {
        guard let json = json else { return nil }
        switch json {
        case .object(let v):
            self = v
        default:
            return nil
        }
    }
}

