public enum Body {
    case buffer(Data)
    case reader(InputStream)
    case writer((OutputStream) throws -> Void)
}

extension Body {
    public var isBuffer: Bool {
        switch self {
        case .buffer: return true
        default: return false
        }
    }

    public var isReader: Bool {
        switch self {
        case .reader: return true
        default: return false
        }
    }

    public var isWriter: Bool {
        switch self {
        case .writer: return true
        default: return false
        }
    }
}

extension Body {
    public mutating func becomeBuffer(deadline: Double = .never) throws -> Data {
        switch self {
        case .buffer(let data):
            return data
        case .reader(let reader):
            let data = Drain(stream: reader, deadline: deadline).data
            self = .buffer(data)
            return data
        case .writer(let writer):
            let drain = Drain()
            try writer(drain)
            let data = drain.data

            self = .buffer(data)
            return data
        }
    }

    public mutating func becomeReader() throws -> InputStream {
        switch self {
        case .reader(let reader):
            return reader
        case .buffer(let buffer):
            let stream = Drain(buffer: buffer)
            self = .reader(stream)
            return stream
        case .writer(let writer):
            let stream = Drain()
            try writer(stream)
            self = .reader(stream)
            return stream
        }
    }

    public mutating func becomeWriter(deadline: Double = .never) throws -> ((OutputStream) throws -> Void) {
        switch self {
        case .buffer(let data):
            let closure: ((OutputStream) throws -> Void) = { writer in
                try writer.write(data, deadline: deadline)
                try writer.flush()
            }
            self = .writer(closure)
            return closure
        case .reader(let reader):
            let closure: ((OutputStream) throws -> Void) = { writer in
                let data = Drain(stream: reader, deadline: deadline).data
                try writer.write(data, deadline: deadline)
                try writer.flush()
            }
            self = .writer(closure)
            return closure
        case .writer(let writer):
            return writer
        }
    }
}

extension Body : Equatable {}

public func == (lhs: Body, rhs: Body) -> Bool {
    switch (lhs, rhs) {
        case let (.buffer(l), .buffer(r)) where l == r: return true
        default: return false
    }
}
