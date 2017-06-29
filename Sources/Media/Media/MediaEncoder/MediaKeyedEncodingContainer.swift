final class MediaKeyedEncodingContainer<Map : EncodingMedia, K : CodingKey> : KeyedEncodingContainerProtocol {
    typealias Key = K
    let encoder: MediaEncoder<Map>
    var codingPath: [CodingKey?]
    
    init(referencing encoder: MediaEncoder<Map>, codingPath: [CodingKey?]) {
        self.encoder = encoder
        self.codingPath = codingPath
    }
    
    func with<T>(pushedKey key: CodingKey?, _ work: () throws -> T) rethrows -> T {
        codingPath.append(key)
        let result: T = try work()
        codingPath.removeLast()
        return result
    }
    
    func encode(_ value: Bool, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode(_ value: Int, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode(_ value: Int8, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode(_ value: Int16, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode(_ value: Int32, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode(_ value: Int64, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode(_ value: UInt, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode(_ value: UInt8, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode(_ value: UInt16, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode(_ value: UInt32, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode(_ value: UInt64, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode(_ value: Float, forKey key: Key)  throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode(_ value: Double, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode(_ value: String, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
    
    func encode<T : Encodable>(_ value: T, forKey key: Key) throws {
        try encoder.with(pushedKey: key) {
            try encoder.stack.withTop { map in
                try map.encode(encoder.box(value), forKey: key)
            }
        }
    }
    
    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> {
        do {
            try encoder.stack.withTop { map in
                try map.encode(Map.makeKeyedContainer(forKey: key), forKey: key)
            }
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
            try encoder.stack.withTop { map in
                try map.encode(Map.makeUnkeyedContainer(forKey: key), forKey: key)
            }
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
            try self.encoder.stack.withTop { map in
                try map.encode(value, forKey: MapSuperKey.super)
            }
        }
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        return MediaReferencingEncoder(referencing: encoder, at: key) { value in
            try self.encoder.stack.withTop { map in
                try map.encode(value, forKey: key)
            }
        }
    }
}
