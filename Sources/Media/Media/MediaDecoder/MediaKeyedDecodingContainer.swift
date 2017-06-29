struct MediaKeyedDecodingContainer<K : CodingKey, Map : DecodingMedia> : KeyedDecodingContainerProtocol {
    typealias Key = K
    
    let decoder: MediaDecoder<Map>
    let map: DecodingMedia
    var codingPath: [CodingKey?]
    
    init(referencing decoder: MediaDecoder<Map>, wrapping map: DecodingMedia) {
        self.decoder = decoder
        self.map = map
        self.codingPath = decoder.codingPath
    }
    
    var allKeys: [Key] {
        return map.allKeys(keyedBy: Key.self)
    }
    
    func contains(_ key: Key) -> Bool {
        return map.contains(key)
    }
    
    func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
        return try decoder.with(pushedKey: key) {
            try map.decodeIfPresent(type, forKey: key)
        }
    }
    
    func decodeIfPresent<T : Decodable>(_ type: T.Type, forKey key: Key) throws -> T? {
        return try decoder.with(pushedKey: key) {
            guard let value = try map.decodeIfPresent(Map.self, forKey: key) else {
                return nil
            }
            
            return try decoder.stack.pushPop(value) {
                try T(from: decoder)
            }
        }
    }
    
    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type,
        forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> {
        return try decoder.with(pushedKey: key) {
            let container = MediaKeyedDecodingContainer<NestedKey, Map>(
                referencing: decoder,
                wrapping: try map.keyedContainer(forKey: key)
            )
            
            return KeyedDecodingContainer(container)
        }
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        return try decoder.with(pushedKey: key) {
            return MediaUnkeyedDecodingContainer(
                referencing: decoder,
                wrapping: try map.unkeyedContainer(forKey: key)
            )
        }
    }
    
    func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: MapSuperKey.super)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
    
    func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        return try decoder.with(pushedKey: key) {
            guard let value = try map.decodeIfPresent(Map.self, forKey: key) else {
                var path = codingPath
                path.append(key)
                
                let context = DecodingError.Context(
                    codingPath: path,
                    debugDescription: "Key not found when expecting non-optional type \(Map.self) for coding key \"\(key)\""
                )
                
                throw DecodingError.keyNotFound(key, context)
            }
            
            return MediaDecoder<Map>(
                referencing: value,
                at: decoder.codingPath,
                userInfo: decoder.userInfo
            )
        }
    }
}

