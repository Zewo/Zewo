public final class Ticker {
    private let internalChannel = Channel<Void>()
    private var stopped: Bool = false

    public var channel: ReceivingChannel<Void> {
        return internalChannel.receivingChannel
    }

    public init(period: Double) {
        co {
            while true {
                nap(for: period)
                if self.stopped { break }
                self.internalChannel.send(Void())
            }
        }
    }

    public func stop() {
        self.stopped = true
    }
}
