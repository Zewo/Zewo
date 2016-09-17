public final class Timer {
    private var internalChannel = Channel<Void>()
    private var stopped: Bool = false

    public var channel: ReceivingChannel<Void> {
        return internalChannel.receivingChannel
    }

    public init(deadline: Double) {
        co {
            wake(at: deadline)
            if !self.stopped {
                self.stopped = true
                self.internalChannel.send(Void())
            }
        }
    }

    public func stop() -> Bool {
        if !stopped {
            self.stopped = true
            return true
        }
        return false
    }
}
