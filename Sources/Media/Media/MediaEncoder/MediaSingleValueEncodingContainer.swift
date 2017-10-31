extension MediaEncoder : SingleValueEncodingContainer {
    func assertCanEncodeSingleValue() {
        guard canEncodeNewElement else {
            preconditionFailure("Attempt to encode with new container when already encoded with a container.")
        }
    }
    
    func encodeNil() throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encodeNil())
    }
    
    func encode(_ value: Bool) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode(_ value: Int) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode(_ value: Int8) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode(_ value: Int16) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode(_ value: Int32) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode(_ value: Int64) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode(_ value: UInt) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode(_ value: UInt8) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode(_ value: UInt16) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode(_ value: UInt32) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode(_ value: UInt64) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode(_ value: Float) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode(_ value: Double) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode(_ value: String) throws {
        assertCanEncodeSingleValue()
        try stack.push(Map.encode(value))
    }
    
    func encode<T : Encodable>(_ value: T) throws {
        assertCanEncodeSingleValue()
        try stack.push(box(value))
    }
}
