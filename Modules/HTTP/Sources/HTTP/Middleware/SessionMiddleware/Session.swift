public final class Session {
    public let token: String
    public var info: [String: Any] = [:]

    init(token: String) {
        self.token = token
    }

    public subscript(key: String) -> Any? {
        get {
            return info[key]
        }
        set {
            info[key] = newValue
        }
    }
}
