final class MediaUnkeyedEncodingContainer<Map : EncodingMedia> : UnkeyedEncodingContainer {

    var count: Int
    
    let encoder: MediaEncoder<Map>
    var codingPath: [CodingKey]
    
    
    init(referencing encoder: MediaEncoder<Map>, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.count = 0
    }
    
    func with<T>(pushedKey key: CodingKey, _ work: () throws -> T) rethrows -> T {
        codingPath.append(key)
        let result: T = try work()
        codingPath.removeLast()

        return result
    }
    
    func encodeNil() throws {
        try encoder.with(pushedKey: count) {
            try encoder.stack.push(Map.encodeNil())
        }
        count += 1
    }
    
    func encode(_ value: Bool) throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(value)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
   }
    
    func encode(_ value: Int) throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(value)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
    }
    
    func encode(_ value: Int8) throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(value)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
    }
    
    func encode(_ value: Int16) throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(value)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
    }
    
    func encode(_ value: Int32) throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(value)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
    }
    
    func encode(_ value: Int64) throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(value)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
   }
    
    func encode(_ value: UInt) throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(value)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
   }
    
    func encode(_ value: UInt8) throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(value)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
   }
    
    func encode(_ value: UInt16) throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(value)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
    }
    
    func encode(_ value: UInt32) throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(value)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
    }
    
    func encode(_ value: UInt64) throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(value)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
    }
    
    func encode(_ value: Float)  throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(value)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
    }
    
    func encode(_ value: Double) throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(value)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
   }
    
    func encode(_ value: String) throws {
        var top = encoder.stack.top
        try top.encode(value)
        encoder.stack.pop()
        encoder.stack.push(top)
    }
    
    func encode<T : Encodable>(_ value: T) throws {
        try encoder.with(pushedKey: count) {
            var top = encoder.stack.top
            try top.encode(encoder.box(value))
            encoder.stack.pop()
            encoder.stack.push(top)
        }
        count += 1
    }
    
    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type
        ) -> KeyedEncodingContainer<NestedKey> {
        do {
            var top = encoder.stack.top
            try top.encode(Map.makeKeyedContainer())
            encoder.stack.pop()
            encoder.stack.push(top)
        } catch {
            fatalError("return a failure container")
        }
        
        let res: KeyedEncodingContainer<NestedKey> = with(pushedKey: count) {
            let container = MediaKeyedEncodingContainer<Map, NestedKey>(
                referencing: encoder,
                codingPath: codingPath
            )
            
            return KeyedEncodingContainer(container)
        }
        count += 1
        return res
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        do {
            var top = encoder.stack.top
            try top.encode(Map.makeUnkeyedContainer())
            encoder.stack.pop()
            encoder.stack.push(top)
        } catch {
            fatalError("return a failure container")
        }
        
        let res: UnkeyedEncodingContainer = with(pushedKey: count) {
            return MediaUnkeyedEncodingContainer(
                referencing: encoder,
                codingPath: codingPath
            )
        }
        count += 1
        return res
    }
    
    func superEncoder() -> Encoder {
        let res: Encoder = MediaReferencingEncoder(referencing: encoder, at: count) { value in
            var top = self.encoder.stack.top
            try top.encode(value)
            self.encoder.stack.pop()
            self.encoder.stack.push(top)
        }
        count += 1
        return res
    }
}
