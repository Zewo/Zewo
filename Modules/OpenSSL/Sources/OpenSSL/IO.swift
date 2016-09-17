import COpenSSL

public enum SSLIOError: Error {
    case io(description: String)
    case shouldRetry(description: String)
    case unsupportedMethod(description: String)
}

public class IO {
	public enum Method {
		case memory

		var method: UnsafeMutablePointer<BIO_METHOD> {
			switch self {
			case .memory:
				return BIO_s_mem()
			}
		}
	}

	var bio: UnsafeMutablePointer<BIO>?

	public init(method: Method = .memory) throws {
		initialize()
		bio = BIO_new(method.method)

		if bio == nil {
			throw SSLIOError.io(description: lastSSLErrorDescription)
		}
	}

	public convenience init(buffer: Data) throws {
		try self.init()
        try write(buffer, length: buffer.count)
	}

	// TODO: crash???
//	deinit {
//		BIO_free(bio)
//	}

	public var pending: Int {
		return BIO_ctrl_pending(bio)
	}

	public var shouldRetry: Bool {
		return (bio!.pointee.flags & BIO_FLAGS_SHOULD_RETRY) != 0
	}

	@discardableResult
    public func write(_ data: Data, length: Int) throws -> Int {
		let result = data.withUnsafeBytes {
			BIO_write(bio, $0, Int32(length))
		}

		if result < 0 {
			if shouldRetry {
				throw SSLIOError.shouldRetry(description: lastSSLErrorDescription)
			} else {
				throw SSLIOError.io(description: lastSSLErrorDescription)
			}
		}

		return Int(result)
	}

    public func read(into buffer: inout Data, length: Int) throws -> Int {
		let result = buffer.withUnsafeMutableBytes {
			BIO_read(bio, $0, Int32(length))
		}

		if result < 0 {
			if shouldRetry {
				throw SSLIOError.shouldRetry(description: lastSSLErrorDescription)
			} else {
				throw SSLIOError.io(description: lastSSLErrorDescription)
			}
		}

		return Int(result)
	}
}
