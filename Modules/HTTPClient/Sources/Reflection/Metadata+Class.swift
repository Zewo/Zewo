extension Metadata {
    struct Class : NominalType {

        static let kind: Kind? = .class
        var pointer: UnsafePointer<_Metadata._Class>

        var nominalTypeDescriptorOffsetLocation: Int {
            return is64BitPlatform ? 8 : 11
        }

        var superclass: Class? {
            guard let superclass = pointer.pointee.superclass else { return nil }
            return Metadata.Class(type: superclass)
        }

    }
}

extension _Metadata {
    struct _Class {
        var kind: Int
        var superclass: Any.Type?
    }
}
