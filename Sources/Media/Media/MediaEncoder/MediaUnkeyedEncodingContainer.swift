final class MediaUnkeyedEncodingContainer<Map : EncodingMedia> : UnkeyedEncodingContainer {
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
    
    func encode(_ value: Bool) throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
    
    func encode(_ value: Int) throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
    
    func encode(_ value: Int8) throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
    
    func encode(_ value: Int16) throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
    
    func encode(_ value: Int32) throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
    
    func encode(_ value: Int64) throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
    
    func encode(_ value: UInt) throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
    
    func encode(_ value: UInt8) throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
    
    func encode(_ value: UInt16) throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
    
    func encode(_ value: UInt32) throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
    
    func encode(_ value: UInt64) throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
    
    func encode(_ value: Float)  throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
    
    func encode(_ value: Double) throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
    
    func encode(_ value: String) throws {
        try encoder.stack.withTop { map in
            try map.encode(value)
        }
    }
    
    func encode<T : Encodable>(_ value: T) throws {
        try encoder.with(pushedKey: nil) {
            try encoder.stack.withTop { map in
                try map.encode(encoder.box(value))
            }
        }
    }
    
    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type
        ) -> KeyedEncodingContainer<NestedKey> {
        do {
            try encoder.stack.withTop { map in
                try map.encode(Map.makeKeyedContainer())
            }
        } catch {
            fatalError("return a failure container")
        }
        
        return with(pushedKey: nil) {
            let container = MediaKeyedEncodingContainer<Map, NestedKey>(
                referencing: encoder,
                codingPath: codingPath
            )
            
            return KeyedEncodingContainer(container)
        }
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        do {
            try encoder.stack.withTop { map in
                try map.encode(Map.makeUnkeyedContainer())
            }
        } catch {
            fatalError("return a failure container")
        }
        
        return with(pushedKey: nil) {
            return MediaUnkeyedEncodingContainer(
                referencing: encoder,
                codingPath: codingPath
            )
        }
    }
    
    func superEncoder() -> Encoder {
        return MediaReferencingEncoder(referencing: encoder, at: nil) { value in
            try self.encoder.stack.withTop { map in
                try map.encode(value)
            }
        }
    }
}
