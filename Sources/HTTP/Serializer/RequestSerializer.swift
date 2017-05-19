import Core
import Venice

internal final class RequestSerializer : Serializer {
    internal func serialize(_ request: Request, deadline: Deadline) throws {
        guard request.contentLength != nil || request.isChunkEncoded else {
            throw SerializerError.noContentLengthOrChunkedEncodingHeaders
        }
        
        try serializeRequestLine(for: request, deadline: deadline)
        try serializeHeaders(for: request, deadline: deadline)
        try serializeBody(for: request, deadline: deadline)
    }
    
    @inline(__always)
    private func serializeRequestLine(for request: Request, deadline: Deadline) throws {
        var requestLine = request.method.description
        requestLine += " "
        requestLine += request.uri.description
        requestLine += " "
        requestLine += request.version.description
        requestLine += "\r\n"
    
        try stream.write(requestLine, deadline: deadline)
    }
}
