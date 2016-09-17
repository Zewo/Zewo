// TODO: Remove uses of advance()
extension Strideable {
    mutating func advance() {
        self = advanced(by: 1)
    }
}
