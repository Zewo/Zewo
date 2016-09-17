public final class FallibleSendingChannel<T> {
    private let channel: FallibleChannel<T>

    init(_ channel: FallibleChannel<T>) {
        self.channel = channel
    }

    public func send(_ result: ChannelResult<T>) {
        return channel.send(result)
    }

    public func send(_ value: T) {
        return channel.send(value)
    }

    func send(_ value: T, clause: UnsafeMutableRawPointer, index: Int) {
        return channel.send(value, clause: clause, index: index)
    }

    public func send(_ error: Error) {
        return channel.send(error)
    }

    func send(_ error: Error, clause: UnsafeMutableRawPointer, index: Int) {
        return channel.send(error, clause: clause, index: index)
    }

    public var closed: Bool {
        return channel.closed
    }
}
