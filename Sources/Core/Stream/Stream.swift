import Venice

public protocol Readable {
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

public protocol Writable {
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
