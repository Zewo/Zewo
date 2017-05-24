import Core

public enum Body {
    public typealias Write = (Writable) throws -> Void
    
    case readable(Readable)
    case writable(Write)
}

extension Body {
    public static var empty: Body {
        return .writable({ _ in })
    }
}

extension Body {
    public var isReadable: Bool {
        switch self {
        case .readable:
            return true
        default:
            return false
        }
    }
    
    public var readable: Readable? {
        switch self {
        case let .readable(readable):
            return readable
        default:
            return nil
        }
    }
    
    public var isWritable: Bool {
        switch self {
        case .writable: return true
        default: return false
        }
    }
    
    public var writable: Write? {
        switch self {
        case let .writable(write):
            return write
        default:
            return nil
        }
    }
}
