import Venice

extension JSON : Content {
    public static var mediaType: MediaType = .json
    
    public static func parse(from readable: Readable, deadline: Deadline) throws -> JSON {
        let parser = JSONParser()
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 4096)
        
        defer {
            buffer.deallocate()
        }
        
        while true {
            let read = try readable.read(buffer, deadline: deadline)
            
            guard !read.isEmpty else {
                break
            }
            
            guard let json = try parser.parse(read) else {
                continue
            }
            
            return json
        }
        
        return try parser.finish()
    }
    
    public func serialize(to writable: Writable, deadline: Deadline) throws {
        let serializer = JSONSerializer()
        
        try serializer.serialize(self) { buffer in
            try writable.write(buffer, deadline: deadline)
        }
    }
}
