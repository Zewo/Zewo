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

public protocol ReadableStream : Readable {
    func open(deadline: Deadline) throws
    func close(deadline: Deadline) throws
}

/// Representation of a type which binary data can be written to.
public protocol Writable {
    /// Read `buffer` timing out at `deadline`.
    func write(_ buffer: UnsafeRawBufferPointer, deadline: Deadline) throws
}

extension Writable {
    public func write(_ buffer: BufferRepresentable, deadline: Deadline) throws {
        try buffer.withBuffer {
            try write($0, deadline: deadline)
        }
    }
}

public protocol WritableStream : Writable {
    func open(deadline: Deadline) throws
    func close(deadline: Deadline) throws
}

public protocol DuplexStream : ReadableStream, WritableStream {}
