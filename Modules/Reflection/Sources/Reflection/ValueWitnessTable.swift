// https://github.com/apple/swift/blob/master/lib/IRGen/ValueWitness.h
struct ValueWitnessTable : PointerType {
    var pointer: UnsafePointer<_ValueWitnessTable>

    private var alignmentMask: Int {
        return 0x0FFFF
    }

    var size: Int {
        return pointer.pointee.size
    }

    var align: Int {
        return (pointer.pointee.align & alignmentMask) + 1
    }

    var stride: Int {
        return pointer.pointee.stride
    }
}

struct _ValueWitnessTable {
    let destroyBuffer: Int
    let initializeBufferWithCopyOfBuffer: Int
    let projectBuffer: Int
    let deallocateBuffer: Int
    let destroy: Int
    let initializeBufferWithCopy: Int
    let initializeWithCopy: Int
    let assignWithCopy: Int
    let initializeBufferWithTake: Int
    let initializeWithTake: Int
    let assignWithTake: Int
    let allocateBuffer: Int
    let initializeBufferWithTakeOrBuffer: Int
    let destroyArray: Int
    let initializeArrayWithCopy: Int
    let initializeArrayWithTakeFrontToBack: Int
    let initializeArrayWithTakeBackToFront: Int
    let size: Int
    let align: Int
    let stride: Int
}
