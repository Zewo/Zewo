import Core
import Venice

internal final class RequestSerializer : Serializer {
    internal func serialize(_ request: Request, deadline: Deadline) throws {
        try checkHeaders(request)
        try serializeRequestLine(request, deadline: deadline)
        try serializeHeaders(request, deadline: deadline)
        try serializeBody(request, deadline: deadline)
    }
    
    @inline(__always)
    private func checkHeaders(_ request: Request) throws {
        switch request.method {
        case .get, .head, .options, .connect, .trace:
            break
        default:
            guard request.contentLength != nil || request.isChunkEncoded else {
                throw SerializerError.noContentLengthOrChunkedEncodingHeaders
            }
        }
    }
    
    @inline(__always)
    private func serializeRequestLine(_ request: Request, deadline: Deadline) throws {
        var requestLine = request.method.description
        requestLine += " "
        requestLine += request.uri.description
        requestLine += " "
        requestLine += request.version.description
        requestLine += "\r\n"
    
        try stream.write(requestLine, deadline: deadline)
    }
}
