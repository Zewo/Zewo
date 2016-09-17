protocol NominalType : MetadataType {
    var nominalTypeDescriptorOffsetLocation: Int { get }
}

extension NominalType {
    var nominalTypeDescriptor: NominalTypeDescriptor {
        let p = UnsafeRawPointer(pointer).assumingMemoryBound(to: Int.self)
        let base = p.advanced(by: nominalTypeDescriptorOffsetLocation)
        return NominalTypeDescriptor(pointer: relativePointer(base: base, offset: base.pointee))
    }

    var fieldTypes: [Any.Type]? {
        guard let function = nominalTypeDescriptor.fieldTypesAccessor else { return nil }
        return (0..<nominalTypeDescriptor.numberOfFields).map {
            let p = UnsafeRawPointer(pointer).assumingMemoryBound(to: Int.self)
            return unsafeBitCast(function(p).advanced(by: $0).pointee, to: Any.Type.self)
        }
    }

    var fieldOffsets: [Int]? {
        let vectorOffset = nominalTypeDescriptor.fieldOffsetVector
        guard vectorOffset != 0 else { return nil }
        return (0..<nominalTypeDescriptor.numberOfFields).map {
            return UnsafeRawPointer(pointer).assumingMemoryBound(to: Int.self)[vectorOffset + $0]
        }
    }
}
