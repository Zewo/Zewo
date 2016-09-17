/// Tests if `value` is `type` or a subclass of `type`
public func value(_ value: Any, is type: Any.Type) -> Bool {
    if type(of: value) == type {
        return true
    }
    guard var subclass = Metadata.Class(type: type(of: value)), let superclass = Metadata.Class(type: type) else {
        return false
    }
    while let parentClass = subclass.superclass {
        if parentClass == superclass {
            return true
        }
        subclass = parentClass
    }
    return false
}

/// Tests equality of any two existential types
public func ==(lhs: Any.Type, rhs: Any.Type) -> Bool {
    return Metadata(type: lhs) == Metadata(type: rhs)
}
