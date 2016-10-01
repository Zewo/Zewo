public struct TCPTLSHost : Host {
    public let host: TCPHost
    public let context: Context

    public init(configuration: Map) throws {
        let certificate: String = try configuration.get("certificate")
        let privateKey: String = try configuration.get("privateKey")
        let certificateChain = configuration["certificateChain"].string

        self.host = try TCPHost(configuration: configuration)
        self.context = try Context(
            certificate: certificate,
            privateKey: privateKey,
            certificateChain: certificateChain
        )
    }

    public func accept(deadline: Double) throws -> Stream {
        let rawStream = try host.accept(deadline: deadline)
        return try SSLStream(context: context, rawStream: rawStream)
    }
}
