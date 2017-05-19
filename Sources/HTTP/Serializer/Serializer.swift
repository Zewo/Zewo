import Core
import Venice

// TODO: Make CustomStringConvertible
public enum SerializerError : Error {
    case invalidContentLength
    case writeExceedsContentLength
    case noContentLengthOrChunkedEncodingHeaders
}

internal class Serializer {
    final class BodyStream : WritableStream {
        enum Mode {
            case contentLength(Int)
            case chunkedEncoding
        }
        
        var bytesRemaining = 0
        
        private let stream: WritableStream
        private let mode: Mode
        
        init(_ stream: WritableStream, mode: Mode) {
            self.stream = stream
            self.mode = mode
            
            if case let .contentLength(contentLength) = mode {
                bytesRemaining = contentLength
            }
        }
        
        func open(deadline: Deadline) throws {}
        
        func done(deadline: Deadline) throws {
            try stream.done(deadline: deadline)
        }
        
        func close() throws {
            try stream.close()
        }
        
        func write(_ buffer: UnsafeRawBufferPointer, deadline: Deadline) throws {
            guard !buffer.isEmpty else {
                return
            }
            
            switch mode {
            case .contentLength:
                if bytesRemaining - buffer.count < 0 {
                    throw SerializerError.writeExceedsContentLength
                }
                
                try stream.write(buffer, deadline: deadline)
                bytesRemaining -= buffer.count
            case .chunkedEncoding:
                let chunkLength = String(buffer.count, radix: 16) + "\r\n"
                try stream.write(chunkLength, deadline: deadline)
                try stream.write(buffer, deadline: deadline)
                try stream.write("\r\n", deadline: deadline)
            }
        }
    }
    
    internal let stream: WritableStream
    private let bufferSize: Int
    private let buffer: UnsafeMutableRawBufferPointer
    
    internal init(stream: WritableStream, bufferSize: Int) {
        self.stream = stream
        self.bufferSize = bufferSize
        self.buffer = UnsafeMutableRawBufferPointer.allocate(count: bufferSize)
    }
    
    deinit {
        buffer.deallocate()
    }
    
    internal func serializeHeaders(for message: Message, deadline: Deadline) throws {
        var header = ""
        
        for (name, value) in message.headers.headers {
            header += name.string
            header += ": "
            header += value
            header += "\r\n"
        }
        
        header += "\r\n"
        
        try stream.write(header, deadline: deadline)
    }
    
    internal func serializeBody(for message: Message, deadline: Deadline) throws {
        if let contentLength = message.contentLength {
            try writeBody(for: message, contentLength: contentLength, deadline: deadline)
        }
        
        if message.isChunkEncoded {
            try writeChunkEncodedBody(for: message, deadline: deadline)
        }
        
        try write(to: stream, body: message.body, deadline: deadline)
    }
    
    @inline(__always)
    private func writeBody(for message: Message, contentLength: Int, deadline: Deadline) throws {
        guard contentLength != 0 else {
            return
        }
        
        guard contentLength > 0 else {
            throw SerializerError.invalidContentLength
        }
        
        let bodyStream = BodyStream(stream, mode: .contentLength(contentLength))
        try write(to: bodyStream, body: message.body, deadline: deadline)
        
        if bodyStream.bytesRemaining > 0 {
            throw SerializerError.invalidContentLength
        }
    }
    
    @inline(__always)
    private func writeChunkEncodedBody(for message: Message, deadline: Deadline) throws {
        let bodyStream = BodyStream(stream, mode: .chunkedEncoding)
        try write(to: bodyStream, body: message.body, deadline: deadline)
        try stream.write("0\r\n\r\n", deadline: deadline)
    }
    
    @inline(__always)
    private func write(to writableStream: WritableStream, body: Body, deadline: Deadline) throws {
        switch body {
        case let .readable(readableStream):
            while true {
                let readBuffer = try readableStream.read(buffer, deadline: deadline)
                
                guard !readBuffer.isEmpty else {
                    break
                }
                
                try writableStream.write(readBuffer, deadline: deadline)
            }
        case let .writable(write):
            try write(writableStream)
        }
    }
}
