import CLibvenice

public final class TCPConnection : Connection {
    public var ip: IP
    var socket: tcpsock?
    public private(set) var closed = true

    internal init(with socket: tcpsock) throws {
        let address = tcpaddr(socket)
        try ensureLastOperationSucceeded()
        self.ip = IP(address: address)
        self.socket = socket
        self.closed = false
    }

    public init(host: String, port: Int, deadline: Double = .never) throws {
        self.ip = try IP(remoteAddress: host, port: port, deadline: deadline)
    }

    public func open(deadline: Double = .never) throws {
        self.socket = tcpconnect(ip.address, deadline.int64milliseconds)
        try ensureLastOperationSucceeded()
        self.closed = false
    }

    public func write(_ buffer: Data, length: Int, deadline: Double) throws -> Int {
        let socket = try getSocket()
        try ensureStreamIsOpen()

        let bytesWritten = buffer.withUnsafeBytes {
            tcpsend(socket, $0, length, deadline.int64milliseconds)
        }

        if bytesWritten == 0 {
            try ensureLastOperationSucceeded()
        }

        return bytesWritten
    }

    public func flush(deadline: Double) throws {
        let socket = try getSocket()
        try ensureStreamIsOpen()

        tcpflush(socket, deadline.int64milliseconds)
        try ensureLastOperationSucceeded()
    }

    public func read(into buffer: inout Data, length: Int, deadline: Double = .never) throws -> Int {
        let socket = try getSocket()
        try ensureStreamIsOpen()

        let bytesRead = buffer.withUnsafeMutableBytes {
            tcprecvlh(socket, $0, 1, length, deadline.int64milliseconds)
        }

        if bytesRead == 0 {
            do {
                try ensureLastOperationSucceeded()
            } catch SystemError.connectionResetByPeer {
                closed = true
                throw StreamError.closedStream(data: Data())
            }
        }

        return bytesRead
    }

    public func close() {
        if !closed, let socket = try? getSocket() {
            tcpclose(socket)
        }

        closed = true
    }

    private func getSocket() throws -> tcpsock {
        guard let socket = self.socket else {
            throw SystemError.socketIsNotConnected
        }
        return socket
    }

    private func ensureStreamIsOpen() throws {
        if closed {
            throw StreamError.closedStream(data: Data())
        }
    }

    deinit {
        if let socket = socket, !closed {
            tcpclose(socket)
        }
    }
}
