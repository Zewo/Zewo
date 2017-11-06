import Venice

/// Representation of a type which binary data can be written to.
public protocol Writable {
    /// Write `buffer` timing out at `deadline`.
    func write(_ buffer: UnsafeRawBufferPointer, deadline: Deadline) throws
}

extension Writable {
    public func write(_ buffer: BufferRepresentable, deadline: Deadline) throws {
        try buffer.withBuffer {
            try write($0, deadline: deadline)
        }
    }
}
