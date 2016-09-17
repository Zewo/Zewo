func mutableStorageForInstance(_ instance: inout Any) -> UnsafeMutablePointer<UInt8> {
    return UnsafeMutablePointer(mutating: storageForInstance(&instance))
}

func storageForInstance(_ instance: inout Any) -> UnsafePointer<UInt8> {
    return withUnsafePointer(to: &instance) { pointer in
        if instance is AnyClass {
            return UnsafePointer(bitPattern: UnsafeRawPointer(pointer).assumingMemoryBound(to: Int.self).pointee)!
        } else if sizeofValue(instance) <= 3 * sizeof(Int.self) {
            return UnsafeRawPointer(pointer).assumingMemoryBound(to: UInt8.self)
        } else {
            return UnsafePointer(bitPattern: UnsafeRawPointer(pointer).assumingMemoryBound(to: Int.self).pointee)!
        }
    }
}

func mutableStorageForInstance<T>(_ instance: inout T) -> UnsafeMutablePointer<UInt8> {
    return UnsafeMutablePointer(mutating: storageForInstance(&instance))
}

func storageForInstance<T>(_ instance: inout T) -> UnsafePointer<UInt8> {
    return withUnsafePointer(to: &instance) { pointer in
        if instance is AnyClass {
            return UnsafePointer(bitPattern: UnsafeRawPointer(pointer).assumingMemoryBound(to: Int.self).pointee)!
        } else {
            return UnsafeRawPointer(pointer).assumingMemoryBound(to: UInt8.self)
        }
    }
}
