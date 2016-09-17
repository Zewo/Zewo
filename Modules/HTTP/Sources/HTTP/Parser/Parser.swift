import CHTTPParser

typealias Parser = UnsafeMutablePointer<http_parser>

extension http_errno : Error, CustomStringConvertible {
    public var description: String {
        return String(cString: http_errno_description(self))
    }
}

extension Request.Method {
    init(code: Int) {
        switch code {
        case 00: self = .delete
        case 01: self = .get
        case 02: self = .head
        case 03: self = .post
        case 04: self = .put
        case 05: self = .connect
        case 06: self = .options
        case 07: self = .trace
        case 08: self = .other(method: "COPY")
        case 09: self = .other(method: "LOCK")
        case 10: self = .other(method: "MKCOL")
        case 11: self = .other(method: "MOVE")
        case 12: self = .other(method: "PROPFIND")
        case 13: self = .other(method: "PROPPATCH")
        case 14: self = .other(method: "SEARCH")
        case 15: self = .other(method: "UNLOCK")
        case 16: self = .other(method: "BIND")
        case 17: self = .other(method: "REBIND")
        case 18: self = .other(method: "UNBIND")
        case 19: self = .other(method: "ACL")
        case 20: self = .other(method: "REPORT")
        case 21: self = .other(method: "MKACTIVITY")
        case 22: self = .other(method: "CHECKOUT")
        case 23: self = .other(method: "MERGE")
        case 24: self = .other(method: "M-SEARCH")
        case 25: self = .other(method: "NOTIFY")
        case 26: self = .other(method: "SUBSCRIBE")
        case 27: self = .other(method: "UNSUBSCRIBE")
        case 28: self = .patch
        case 29: self = .other(method: "PURGE")
        case 30: self = .other(method: "MKCALENDAR")
        case 31: self = .other(method: "LINK")
        case 32: self = .other(method: "UNLINK")
        default: self = .other(method: "UNKNOWN")
        }
    }
}

extension UnsafeMutablePointer {
    func withPointee<R>(_ body: (_ pointer: inout Pointee) throws -> R) rethrows -> R {
        return try body(&pointee)
    }
}
