final class MediaKeyedEncodingContainer<Map : EncodingMedia, K : CodingKey> : KeyedEncodingContainerProtocol {
    
    typealias Key = K
    let encoder: MediaEncoder<Map>
    var codingPath: [CodingKey]
    
    init(referencing encoder: MediaEncoder<Map>, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.codingPath = codingPath
    }
    
    func with<T>(pushedKey key: CodingKey, _ work: () throws -> T) rethrows -> T {
        codingPath.append(key)
        
        let result: T = try work()

        codingPath.removeLast()
        return result
    }
    
    
    func encodeNil(forKey key: K) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.push(Map.encodeNil())
        }
    }
    
    func encode(_ value: Bool, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode(_ value: Int, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode(_ value: Int8, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode(_ value: Int16, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode(_ value: Int32, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode(_ value: Int64, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode(_ value: UInt, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode(_ value: UInt8, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode(_ value: UInt16, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode(_ value: UInt32, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode(_ value: UInt64, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode(_ value: Float, forKey key: Key)  throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode(_ value: Double, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode(_ value: String, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(value, forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func encode<T : Encodable>(_ value: T, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            var top = encoder.stack.top
            try top.encode(encoder.box(value), forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        }
    }
    
    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> {
        do {
            var top = encoder.stack.top
            try top.encode(Map.makeKeyedContainer(forKey: key), forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        } catch {
            fatalError("return a failure container")
        }
        
        return with(pushedKey: key) {
            let container = MediaKeyedEncodingContainer<Map, NestedKey>(
                referencing: encoder,
                codingPath: codingPath
            )
            
            return KeyedEncodingContainer(container)
        }
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        do {
            var top = encoder.stack.top
            try top.encode(Map.makeUnkeyedContainer(forKey: key), forKey: key)
            encoder.stack.pop()
            encoder.stack.push(top)
        } catch {
            fatalError("return a failure container")
        }
        
        return with(pushedKey: key) {
            return MediaUnkeyedEncodingContainer(
                referencing: encoder,
                codingPath: codingPath
            )
        }
    }
    
    func superEncoder() -> Encoder {
        return MediaReferencingEncoder(referencing: encoder, at: MapSuperKey.super) { value in
            var top = self.encoder.stack.top
            try top.encode(value, forKey: MapSuperKey.super)
            self.encoder.stack.pop()
            self.encoder.stack.push(top)
        }
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        return MediaReferencingEncoder(referencing: encoder, at: key) { value in
            var top = self.encoder.stack.top
            try top.encode(value, forKey: key)
            self.encoder.stack.pop()
            self.encoder.stack.push(top)        }
    }
}
