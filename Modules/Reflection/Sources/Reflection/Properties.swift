private struct HashedType : Hashable {
    let hashValue: Int
    init(_ type: Any.Type) {
        hashValue = unsafeBitCast(type, to: Int.self)
    }
}

private func == (lhs: HashedType, rhs: HashedType) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

private var cachedProperties = [HashedType : Array<Property.Description>]()

/// An instance property
public struct Property {
    public let key: String
    public let value: Any

    /// An instance property description
    public struct Description {
        public let key: String
        public let type: Any.Type
        let offset: Int
    }
}

/// Retrieve properties for `instance`
public func properties(_ instance: Any) throws -> [Property] {
    let props = try properties(type(of: instance))
    var copy = instance
    return props.map { nextPropertyForDescription($0, pointer: storageForInstance(&copy)) }
}

/// Retrieve property descriptions for `type`
public func properties(_ type: Any.Type) throws -> [Property.Description] {
    if let properties = cachedProperties[HashedType(type)] {
        return properties
    } else if let nominalType = Metadata.Struct(type: type) {
        let properties = try propertiesForNominalType(nominalType)
        cachedProperties[HashedType(type)] = properties
        return properties
    } else if let nominalType = Metadata.Class(type: type) {
        let properties = try propertiesForNominalType(nominalType)
        cachedProperties[HashedType(type)] = properties
        return properties
    } else {
        throw ReflectionError.notStruct(type: type)
    }
}

private func nextPropertyForDescription(_ description: Property.Description, pointer: UnsafePointer<UInt8>) -> Property {
    return Property(key: description.key, value: AnyExistentialContainer(type: description.type, pointer: pointer.advanced(by: description.offset)).any)
}

private func propertiesForNominalType<T : NominalType>(_ type: T) throws -> [Property.Description] {
    guard type.nominalTypeDescriptor.numberOfFields != 0 else { return [] }
    guard let fieldTypes = type.fieldTypes, let fieldOffsets = type.fieldOffsets else {
        throw ReflectionError.unexpected
    }
    let fieldNames = type.nominalTypeDescriptor.fieldNames
    return (0..<type.nominalTypeDescriptor.numberOfFields).map { i in
        return Property.Description(key: fieldNames[i], type: fieldTypes[i], offset: fieldOffsets[i])
    }
}
