import COpenSSL

public struct SSLServer : Host {
	public let server: Host
	public let context: Context

	public init(server: Host, context: Context) throws {
		self.server = server
		self.context = context
	}

	public func accept(deadline: Double) throws -> Stream {
		let stream = try server.accept(deadline: deadline)
		let connection = try SSLConnection(context: context, rawStream: stream)
		try connection.open(deadline: deadline)
		return connection
	}
}
