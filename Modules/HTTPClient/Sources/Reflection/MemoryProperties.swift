public func alignof(_ x: Any.Type) -> Int {
    return Metadata(type: x).valueWitnessTable.align
}

public func sizeof(_ x: Any.Type) -> Int {
    return Metadata(type: x).valueWitnessTable.size
}

public func strideof(_ x: Any.Type) -> Int {
    return Metadata(type: x).valueWitnessTable.stride
}

public func alignofValue(_ x: Any) -> Int {
    return alignof(type(of: x))
}

public func sizeofValue(_ x: Any) -> Int {
    return sizeof(type(of: x))
}

public func strideofValue(_ x: Any) -> Int {
    return strideof(type(of: x))
}
