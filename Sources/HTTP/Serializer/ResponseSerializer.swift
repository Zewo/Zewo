import Core
import Venice

internal final class ResponseSerializer : Serializer {
    internal func serialize(_ response: Response, deadline: Deadline) throws -> Bool {
        try serializeStatusLine(response, deadline: deadline)
        try serializeHeaders(response, deadline: deadline)
        try serializeBody(response, deadline: deadline)
        return response.contentLength != nil || response.isChunkEncoded
    }
    
    @inline(__always)
    private func serializeStatusLine(_ response: Response, deadline: Deadline) throws {
        var header = response.version.description
        header += " "
        header += response.status.description
        header += "\r\n"
        
        for cookie in response.cookieHeaders {
            header += "Set-Cookie: "
            header += cookie
            header += "\r\n"
        }
        
        try stream.write(header, deadline: deadline)
    }
}
