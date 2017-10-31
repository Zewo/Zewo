import CHTTPParser
import Core
import Foundation
import Venice

extension Request.Method {
    internal init(code: http_method) {
        switch code {
        case HTTP_DELETE: self = .delete
        case HTTP_GET: self = .get
        case HTTP_HEAD: self = .head
        case HTTP_POST: self = .post
        case HTTP_PUT: self = .put
        case HTTP_CONNECT: self = .connect
        case HTTP_OPTIONS: self = .options
        case HTTP_TRACE: self = .trace
        case HTTP_COPY: self = .other("COPY")
        case HTTP_LOCK: self = .other("LOCK")
        case HTTP_MKCOL: self = .other("MKCOL")
        case HTTP_MOVE: self = .other("MOVE")
        case HTTP_PROPFIND: self = .other("PROPFIND")
        case HTTP_PROPPATCH: self = .other("PROPPATCH")
        case HTTP_SEARCH: self = .other("SEARCH")
        case HTTP_UNLOCK: self = .other("UNLOCK")
        case HTTP_BIND: self = .other("BIND")
        case HTTP_REBIND: self = .other("REBIND")
        case HTTP_UNBIND: self = .other("UNBIND")
        case HTTP_ACL: self = .other("ACL")
        case HTTP_REPORT: self = .other("REPORT")
        case HTTP_MKACTIVITY: self = .other("MKACTIVITY")
        case HTTP_CHECKOUT: self = .other("CHECKOUT")
        case HTTP_MERGE: self = .other("MERGE")
        case HTTP_MSEARCH: self = .other("M-SEARCH")
        case HTTP_NOTIFY: self = .other("NOTIFY")
        case HTTP_SUBSCRIBE: self = .other("SUBSCRIBE")
        case HTTP_UNSUBSCRIBE: self = .other("UNSUBSCRIBE")
        case HTTP_PATCH: self = .patch
        case HTTP_PURGE: self = .other("PURGE")
        case HTTP_MKCALENDAR: self = .other("MKCALENDAR")
        case HTTP_LINK: self = .other("LINK")
        case HTTP_UNLINK: self = .other("UNLINK")
        default: self = .other("UNKNOWN")
        }
    }
}

extension URI {
    init?(buffer: UnsafeRawBufferPointer, isConnect: Bool) {
        let uri = parse_uri(
            buffer.baseAddress?.assumingMemoryBound(to: Int8.self),
            buffer.count,
            isConnect ? 1 : 0
        )
        
        if uri.error == 1 {
            return nil
        }
        
        let scheme: String?
        let userInfo: UserInfo?
        let host: String?
        let port: Int?
        let path: String?
        let query:  String?
        let fragment: String?
        
        if uri.field_set & 1 != 0 {
            scheme = URI.substring(buffer: buffer, start: uri.scheme_start, end: uri.scheme_end)
        } else {
            scheme = nil
        }
        
        if uri.field_set & 2 != 0 {
            host = URI.substring(buffer: buffer, start: uri.host_start, end: uri.host_end)
        } else {
            host = nil
        }
        
        if uri.field_set & 4 != 0 {
            port = Int(uri.port)
        } else {
            port = nil
        }
        
        if uri.field_set & 8 != 0 {
            path = URI.substring(buffer: buffer, start: uri.path_start, end: uri.path_end)
        } else {
            path = nil
        }
        
        if uri.field_set & 16 != 0 {
            query = URI.substring(buffer: buffer, start: uri.query_start, end: uri.query_end)
        } else {
            query = nil
        }
        
        if uri.field_set & 32 != 0 {
            fragment = URI.substring(buffer: buffer, start: uri.fragment_start, end: uri.fragment_end)
        } else {
            fragment = nil
        }
        
        if uri.field_set & 64 != 0 {
            let userInfoString = URI.substring(
                buffer: buffer,
                start: uri.user_info_start,
                end: uri.user_info_end
            )
            
            userInfo = URI.userInfo(userInfoString)
        } else {
            userInfo = nil
        }
        
        self.init(
            scheme: scheme,
            userInfo: userInfo,
            host: host,
            port: port,
            path: path,
            query: query,
            fragment: fragment
        )
    }
    
    @inline(__always)
    private static func substring(buffer: UnsafeRawBufferPointer, start: UInt16, end: UInt16) -> String {
        let bytes = [UInt8](buffer[Int(start) ..< Int(end)]) + [0]
        
        return bytes.withUnsafeBufferPointer { (pointer: UnsafeBufferPointer<UInt8>) -> String in
            return String(cString: pointer.baseAddress!)
        }
    }
    
    @inline(__always)
    private static func userInfo(_ string: String?) -> URI.UserInfo? {
        guard let string = string else {
            return nil
        }
        
        let components = string.components(separatedBy: ":")
        
        if components.count == 2 {
            return URI.UserInfo(
                username: components[0],
                password: components[1]
            )
        }
        
        return nil
    }
}

internal final class RequestParser : Parser {
    private var requests: [Request] = []
    
    public init(stream: Readable, bufferSize: Int = 2048) {
        super.init(stream: stream, bufferSize: bufferSize, type: HTTP_REQUEST)
    }
    
    public func parse(deadline: Deadline) throws -> Request {
        while true {
            guard requests.isEmpty else {
                return requests.removeFirst()
            }
            
            try read(deadline: deadline)
        }
    }
    
    override func headersComplete(context: Parser.Context, body: Parser.BodyStream, method: Int32, http_major: Int16, http_minor: Int16) -> Bool {
        guard let uri = context.uri else {
            return false
        }
        
        let request = Request(
            method: Request.Method(code: http_method(rawValue: UInt32(Int(method)) )),
            uri: uri,
            headers: context.headers,
            version: Version(major: Int(http_major), minor: Int(http_minor)),
            body: .readable(body)
        )
        
        requests.append(request)
        return true
    }
}
