import Venice

/// Representation of a type which binary data can be read from.
public protocol Readable {
    /// Read binary data into `buffer` timing out at `deadline`.
    func read(
        _ buffer: UnsafeMutableRawBufferPointer,
        deadline: Deadline
    ) throws -> UnsafeRawBufferPointer
}

extension Readable {
    public func read<B :  BufferInitializable>(
        _ buffer: UnsafeMutableRawBufferPointer,
        deadline: Deadline
    ) throws -> B {
        let buffer = try read(buffer, deadline: deadline)
        return B(buffer)
    }
}
