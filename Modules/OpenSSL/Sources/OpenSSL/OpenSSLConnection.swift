import COpenSSL

public final class SSLConnection : Connection {

	private enum Raw {
		case stream(Stream)
		case connection(Connection)

		var stream: Stream {
			switch self {
			case .stream(let stream):
				return stream
			case .connection(let connection):
				return connection
			}
		}
	}

	private let raw: Raw
	private let context: Context
	private let session: SSLSession
	private let readIO: IO
	private let writeIO: IO

	public var closed: Bool = false

	public convenience init(context: Context, rawStream: Stream) throws {
		try self.init(context: context, raw: .stream(rawStream))
	}

	public convenience init(context: Context, rawConnection: Connection) throws {
		try self.init(context: context, raw: .connection(rawConnection))
	}

	private init(context: Context, raw: Raw) throws {
		initialize()

		self.context = context
		self.raw = raw

		readIO = try IO()
		writeIO = try IO()

		session = try SSLSession(context: context)
		session.setIO(readIO: readIO, writeIO: writeIO)

		if let hostname = context.sniHostname {
			try session.setServerNameIndication(hostname: hostname)
		}

		if context.mode == .server {
			session.setAcceptState()
		} else {
			session.setConnectState()
		}
	}

	public func open(deadline: Double) throws {
		if case .connection(let rawConnection) = raw {
			try rawConnection.open(deadline: deadline)
		}

		try handshake(deadline: deadline)
	}

	private func handshake(deadline: Double) throws {
        var buffer = Data(count: 2048)
		let flushAndReceive = {
			try self.flush(deadline: deadline)
			let bytesRead = try self.raw.stream.read(into: &buffer, deadline: deadline)
            try self.readIO.write(buffer, length: bytesRead)
		}
		while !session.initializationFinished {
			do {
				try session.handshake()
			} catch SSLSessionError.wantRead {
				if context.mode == .client {
					try flushAndReceive()
				}
			}
			if context.mode == .server {
				try flushAndReceive()
			}
		}
	}

    public func read(into buffer: inout Data, length: Int, deadline: Double) throws -> Int {
        var rawBuffer = Data(count: length)
		while true {
			do {
                let bytesRead = try session.read(into: &buffer, length: length)
				if bytesRead > 0 {
					return bytesRead
				}
			} catch SSLSessionError.wantRead {
				do {
                    let bytesRead = try raw.stream.read(into: &rawBuffer, length: length, deadline: deadline)
                    try readIO.write(rawBuffer, length: bytesRead)
				} catch StreamError.closedStream(let data) {
					if data.count > 0 {
						try readIO.write(data, length: data.count)
					} else {
						throw StreamError.closedStream(data: Data())
					}
				}
			} catch SSLSessionError.zeroReturn {
				throw StreamError.closedStream(data: Data())
			}
		}
	}

    public func write(_ data: Data, length: Int, deadline: Double) throws -> Int {
        return session.write(data, length: length)
	}

	public func flush(deadline: Double) throws {
		do {
            var buffer = Data(count: writeIO.pending)
            let bytesRead = try writeIO.read(into: &buffer, length: buffer.count)
            try raw.stream.write(buffer, length: bytesRead, deadline: deadline)
			try raw.stream.flush(deadline: deadline)
		} catch SSLIOError.shouldRetry { }
	}

	public func close() {
		// TODO: http://stackoverflow.com/questions/28056056/handling-ssl-shutdown-correctly
//		session.shutdown()
        raw.stream.close()
	}

}
