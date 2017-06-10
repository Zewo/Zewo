import Core
import Venice

public protocol ReadableStream : Readable {
    func open(deadline: Deadline) throws
    func close(deadline: Deadline) throws
}

public protocol WritableStream : Writable {
    func open(deadline: Deadline) throws
    func close(deadline: Deadline) throws
}

public protocol DuplexStream : ReadableStream, WritableStream {}
