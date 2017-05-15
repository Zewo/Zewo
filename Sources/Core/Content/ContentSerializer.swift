import Venice

public protocol ContentSerializer {
    init()
    func serialize(_ content: Content, bufferSize: Int, body: (UnsafeRawBufferPointer) throws -> Void) throws
}

extension ContentSerializer {
    public static func serialize(
        _ content: Content,
        stream: WritableStream,
        bufferSize: Int = 4096,
        deadline: Deadline
    ) throws {
        let serializer = self.init()

        try serializer.serialize(content, bufferSize: bufferSize) { buffer in
            try stream.write(buffer, deadline: deadline)
        }
    }
}
