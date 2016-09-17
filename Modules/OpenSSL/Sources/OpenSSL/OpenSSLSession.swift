import COpenSSL

public enum SSLSessionError: Error {
    case session(description: String)
    case wantRead(description: String)
    case wantWrite(description: String)
    case zeroReturn(description: String)
}

public class SSLSession {
	public enum State: Int32 {
		case connect		= 0x1000
		case accept			= 0x2000
		case mask			= 0x0FFF
		case initial		= 0x3000
		case before			= 0x4000
		case ok				= 0x03
		case renegotiate	= 0x3004
		case error			= 0x05
		case unknown        = -1
	}

	var ssl: UnsafeMutablePointer<SSL>?

	public init(context: Context) throws {
		initialize()

		ssl = SSL_new(context.context)

		if ssl == nil {
			throw SSLSessionError.session(description: lastSSLErrorDescription)
		}
	}

	deinit {
		shutdown()
	}

	public func setAcceptState() {
		SSL_set_accept_state(ssl)
	}

	public func setConnectState() {
		SSL_set_connect_state(ssl)
	}

	public func setServerNameIndication(hostname: String) throws {
		let result = hostname.withCString {
			SSL_ctrl(ssl, SSL_CTRL_SET_TLSEXT_HOSTNAME, Int(TLSEXT_NAMETYPE_host_name), UnsafeMutableRawPointer(mutating: $0))
		}
		if result == 0 {
			throw SSLSessionError.session(description: lastSSLErrorDescription)
		}
	}

	public var stateDescription: String {
		return String(validatingUTF8: SSL_state_string_long(ssl))!
	}

	public var state: State {
		let stateNumber = SSL_state(ssl)
		let state = State(rawValue: stateNumber)
		return state ?? .unknown
	}

	public var peerCertificate: Certificate? {
		guard let certificate = SSL_get_peer_certificate(ssl) else {
			return nil
		}

		defer {
			X509_free(certificate)
		}

		return Certificate(certificate: certificate)
	}

	public func setIO(readIO: IO, writeIO: IO) {
		SSL_set_bio(ssl, readIO.bio, writeIO.bio)
	}

	var initializationFinished: Bool {
		return SSL_state(ssl) == SSL_ST_OK
	}

	public func handshake() throws {
		let result = SSL_do_handshake(ssl)

		if result <= 0 {
			switch SSL_get_error(ssl, result) {
			case SSL_ERROR_WANT_READ:
				throw SSLSessionError.wantRead(description: lastSSLErrorDescription)
			case SSL_ERROR_WANT_WRITE:
				throw SSLSessionError.wantWrite(description: lastSSLErrorDescription)
			default:
				throw SSLSessionError.session(description: lastSSLErrorDescription)
			}
		}
	}

    public func write(_ data: Data, length: Int) -> Int {
		let result = data.withUnsafeBytes {
			SSL_write(ssl, $0, Int32(length))
		}
        // TODO: Deal with errors.
        return Int(result)
	}

    public func read(into buffer: inout Data, length: Int) throws -> Int {
		let result = buffer.withUnsafeMutableBytes {
			SSL_read(ssl, $0, Int32(length))
		}

		if result <= 0 {
			let error = SSL_get_error(ssl, result)
			switch error {
			case SSL_ERROR_WANT_READ:
				throw SSLSessionError.wantRead(description: lastSSLErrorDescription)
			case SSL_ERROR_WANT_WRITE:
				throw SSLSessionError.wantWrite(description: lastSSLErrorDescription)
			case SSL_ERROR_ZERO_RETURN:
				throw SSLSessionError.zeroReturn(description: lastSSLErrorDescription)
			default:
				throw SSLSessionError.session(description: lastSSLErrorDescription)
			}
		}

		return Int(result)
	}

	public func shutdown() {
		SSL_shutdown(ssl)
		SSL_free(ssl)
	}

}
