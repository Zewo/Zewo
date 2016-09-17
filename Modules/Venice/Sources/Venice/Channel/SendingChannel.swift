public final class SendingChannel<T> {
    private let channel: Channel<T>

    internal init(_ channel: Channel<T>) {
        self.channel = channel
    }

    public func send(_ value: T) {
        return channel.send(value)
    }

    internal func send(_ value: T, clause: UnsafeMutableRawPointer, index: Int) {
        return channel.send(value, clause: clause, index: index)
    }

    public var closed: Bool {
        return channel.closed
    }
}
