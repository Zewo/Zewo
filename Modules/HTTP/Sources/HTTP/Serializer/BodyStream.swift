public enum BodyStreamError: Error {
    case receiveUnsupported
}

final class BodyStream : Stream {
    var closed = false
    let transport: Stream

    init(_ transport: Stream) {
        self.transport = transport
    }

    func close() {
        closed = true
    }

    func read(into buffer: inout Data, length: Int, deadline: Double) throws -> Int {
        throw BodyStreamError.receiveUnsupported
    }

    func write(_ buffer: Data, length: Int, deadline: Double) throws -> Int {
        if closed {
            throw StreamError.closedStream(data: buffer)
        }

        let newLine: Data = Data([13, 10])
        try transport.write(String(length, radix: 16))
        try transport.write(newLine)
        try transport.write(buffer, length: length)
        try transport.write(newLine)

        return length
    }

    func flush(deadline: Double = .never) throws {
        try transport.flush()
    }
}
