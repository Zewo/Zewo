/// Create a class or struct with a constructor method. Return a value of `property.type` for each property. Classes must conform to `Initializable`.
public func construct<T>(_ type: T.Type = T.self, constructor: (Property.Description) throws -> Any) throws -> T {
    if Metadata(type: T.self)?.kind == .struct {
        return try constructValueType(constructor)
    } else {
        throw ReflectionError.notStruct(type: T.self)
    }
}

private func constructValueType<T>(_ constructor: (Property.Description) throws -> Any) throws -> T {
    guard Metadata(type: T.self)?.kind == .struct else { throw ReflectionError.notStruct(type: T.self) }
    let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    defer { pointer.deallocate(capacity: 1) }
    var values: [Any] = []
    let p = UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: UInt8.self)
    try constructType(storage: p, values: &values, properties: properties(T.self), constructor: constructor)
    return pointer.move()
}

private func constructType(storage: UnsafeMutablePointer<UInt8>, values: inout [Any], properties: [Property.Description], constructor: (Property.Description) throws -> Any) throws {
    for property in properties {
        var val = try constructor(property)
        guard value(val, is: property.type) else { throw ReflectionError.valueIsNotType(value: val, type: property.type) }
        values.append(val)
        storage.advanced(by: property.offset).consume(buffer: buffer(instance: &val))
    }
}

/// Create a class or struct from a dictionary. Classes must conform to `Initializable`.
public func construct<T>(_ type: T.Type = T.self, dictionary: [String: Any]) throws -> T {
    return try construct(constructor: constructorForDictionary(dictionary))
}

private func constructorForDictionary(_ dictionary: [String: Any]) -> (Property.Description) throws -> Any {
    return { property in
        if let value = dictionary[property.key] {
            return value
        } else if let expressibleByNilLiteral = property.type as? ExpressibleByNilLiteral.Type {
            return expressibleByNilLiteral.init(nilLiteral: ())
        } else {
            throw ReflectionError.requiredValueMissing(key: property.key)
        }
    }
}
