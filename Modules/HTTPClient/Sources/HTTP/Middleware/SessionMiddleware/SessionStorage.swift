public protocol SessionStorage : class {
    func fetchSession(key: Cookie.Hash) -> Session?
    func save(key: Cookie.Hash, session: Session)
}

public final class SessionInMemoryStorage : SessionStorage {
    private var sessions: [Cookie.Hash: Session] = [:]

    public func fetchSession(key: Cookie.Hash) -> Session? {
        return sessions[key]
    }

    public func save(key: Cookie.Hash, session: Session) {
        sessions[key] = session
    }
}
