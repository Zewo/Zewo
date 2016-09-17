public final class ReceivingChannel<T> : Sequence {
    private let channel: Channel<T>

    internal init(_ channel: Channel<T>) {
        self.channel = channel
    }

    @discardableResult
    public func receive() -> T? {
        return channel.receive()
    }

    public func makeIterator() -> ChannelGenerator<T> {
        return ChannelGenerator(channel: self)
    }

    public func close() {
        channel.close()
    }

    internal func registerReceive(_ clause: UnsafeMutableRawPointer, index: Int) {
        return channel.registerReceive(clause, index: index)
    }

    internal func getValueFromBuffer() -> T? {
        return channel.getValueFromBuffer()
    }
}
