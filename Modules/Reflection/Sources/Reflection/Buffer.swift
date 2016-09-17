func buffer(instance: inout Any) -> UnsafeBufferPointer<UInt8> {
    let size = sizeofValue(instance)
    let pointer: UnsafePointer<UInt8> = withUnsafePointer(to: &instance) { pointer in
        if size <= 3 * sizeof(Int.self) {
            return UnsafeRawPointer(pointer).assumingMemoryBound(to: UInt8.self)
        } else {
            return UnsafePointer(bitPattern: UnsafeRawPointer(pointer).assumingMemoryBound(to: Int.self)[0])!
        }
    }
    return UnsafeBufferPointer(start: pointer, count: size)
}

extension UnsafeMutablePointer {
    func consume(buffer: UnsafeBufferPointer<UInt8>) {
        let pointer = UnsafeMutableRawPointer(self).assumingMemoryBound(to: UInt8.self)
        for (i, byte) in buffer.enumerated() {
            pointer[i] = byte
        }
    }
}
