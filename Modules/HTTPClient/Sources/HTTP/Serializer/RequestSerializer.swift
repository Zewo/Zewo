public class RequestSerializer {
    let stream: Stream
    let bufferSize: Int

    public init(stream: Stream, bufferSize: Int = 2048) {
        self.stream = stream
        self.bufferSize = bufferSize
    }

    public func serialize(_ request: Request) throws {
        let newLine: Data = Data([13, 10])

        try stream.write("\(request.method) \(request.url.absoluteString) HTTP/\(request.version.major).\(request.version.minor)")
        try stream.write(newLine)

        for (name, value) in request.headers.headers {
            try stream.write("\(name): \(value)")
            try stream.write(newLine)
        }

        try stream.write(newLine)

        switch request.body {
        case .buffer(let buffer):
            try stream.write(buffer)
        case .reader(let reader):
            var buffer = Data(count: bufferSize)

            while !reader.closed {
                let bytesRead = try reader.read(into: &buffer)

                if bytesRead == 0 {
                    break
                }

                try stream.write(String(bytesRead, radix: 16))
                try stream.write(newLine)
                try stream.write(buffer, length: bytesRead)
                try stream.write(newLine)
            }

            try stream.write("0")
            try stream.write(newLine)
            try stream.write(newLine)
        case .writer(let writer):
            let body = BodyStream(stream)
            try writer(body)

            try stream.write("0")
            try stream.write(newLine)
            try stream.write(newLine)
        }

        try stream.flush()
    }
}
