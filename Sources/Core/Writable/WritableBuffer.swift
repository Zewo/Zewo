import Venice

public final class WritableBuffer : Writable {
    public private(set) var buffer: [UInt8] = []
    
    public init() {}
    
    public func write(_ buffer: UnsafeRawBufferPointer, deadline: Deadline) throws {
        self.buffer.append(contentsOf: buffer)
    }
}
