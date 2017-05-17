import struct Foundation.Data

extension ContentType {
    public static var plainText: ContentType {
        return ContentType(
            mediaType: .plainText,
            parser: PlainTextParser.self,
            serializer: PlainTextSerializer.self
        )
    }
}

public struct PlainTextParser : ContentParser {
    public init() {}
    
    @discardableResult
    public func parse(_ buffer: UnsafeRawBufferPointer) throws -> Content? {
        guard let string = String(data: Data(buffer), encoding: .utf8) else {
            return nil
        }
        
        return .string(string)
    }
}

public struct PlainTextSerializer : ContentSerializer {
    public init() {}
    
    public func serialize(
        _ content: Content,
        bufferSize: Int,
        body: (UnsafeRawBufferPointer) throws -> Void
    ) throws {
        guard case let .string(string) = content else {
            throw ContentSerializerError.invalidInput
        }
        
        try string.withBuffer { buffer in
            try body(buffer)
        }
    }
}
