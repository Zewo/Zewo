import Core

class MediaDecoder<Map : DecodingMedia> : Decoder {
    var stack: Stack<DecodingMedia>
    var codingPath: [CodingKey?]
    var userInfo: [CodingUserInfoKey: Any]
    
    init(
        referencing map: DecodingMedia,
        at codingPath: [CodingKey?] = [],
        userInfo: [CodingUserInfoKey: Any]
    ) {
        self.stack = Stack()
        self.stack.push(map)
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    func with<T>(pushedKey: CodingKey?, _ work: () throws -> T) rethrows -> T {
        codingPath.append(pushedKey)
        let result: T = try work()
        codingPath.removeLast()
        return result
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        let container = MediaKeyedDecodingContainer<Key, Map>(
            referencing: self,
            wrapping: try stack.top.keyedContainer()
        )
        
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return MediaUnkeyedDecodingContainer<Map>(
            referencing: self,
            wrapping: try stack.top.unkeyedContainer()
        )
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return MediaSingleValueDecodingContainer<Map>(
            referencing: self,
            wrapping: try stack.top.singleValueContainer()
        )
    }
}
