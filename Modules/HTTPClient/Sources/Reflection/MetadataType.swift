protocol MetadataType : PointerType {
    static var kind: Metadata.Kind? { get }
}

extension MetadataType {
    var valueWitnessTable: ValueWitnessTable {
        let p = UnsafeRawPointer(pointer).assumingMemoryBound(to: UnsafePointer<Int>.self)
        return ValueWitnessTable(pointer: p.advanced(by: -1).pointee)
    }

    var kind: Metadata.Kind {
        return Metadata.Kind(flag: UnsafeRawPointer(pointer).assumingMemoryBound(to: Int.self).pointee)
    }

    init?(type: Any.Type) {
        self.init(pointer: unsafeBitCast(type, to: UnsafePointer<Int>.self))
        if let kind = type(of: self).kind, kind != self.kind {
            return nil
        }
    }
}
