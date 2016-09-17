struct AnyExistentialContainer {
    var buffer: (Int, Int, Int)
    var type: Any.Type

    init(type: Any.Type, pointer: UnsafePointer<UInt8>) {
        self.type = type
        if sizeof(type) <= 3 * sizeof(Int.self) {
            self.buffer = UnsafeRawPointer(pointer).assumingMemoryBound(to: (Int, Int, Int).self).pointee
        } else {
            self.buffer = (pointer.hashValue, 0, 0)
        }
    }

    var any: Any {
        return unsafeBitCast(self, to: Any.self)
    }
}
