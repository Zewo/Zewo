public final class FallibleReceivingChannel<T> : Sequence {
    private let channel: FallibleChannel<T>

    init(_ channel: FallibleChannel<T>) {
        self.channel = channel
    }

    @discardableResult
    public func receive() throws -> T? {
        return try channel.receive()
    }

    @discardableResult
    public func receiveResult() -> ChannelResult<T>? {
        return channel.receiveResult()
    }

    public func makeIterator() -> FallibleChannelGenerator<T> {
        return FallibleChannelGenerator(channel: self)
    }

    public func close() {
        channel.close()
    }

    func registerReceive(_ clause: UnsafeMutableRawPointer, index: Int) {
        return channel.registerReceive(clause, index: index)
    }

    func getResultFromBuffer() -> ChannelResult<T>? {
        return channel.getResultFromBuffer()
    }
}
