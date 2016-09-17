extension Metadata {
    struct Tuple : MetadataType {
        static let kind: Kind? = .tuple
        var pointer: UnsafePointer<Int>
        var labels: [String?] {
            guard var pointer = UnsafePointer<CChar>(bitPattern: pointer[2]) else { return [] }
            var labels = [String?]()
            var string = ""
            while pointer.pointee != 0 {
                guard pointer.pointee != 32 else {
                    labels.append(string.isEmpty ? nil : string)
                    string = ""
                    pointer.advance()
                    continue
                }
                string.append(String(UnicodeScalar(UInt8(bitPattern: pointer.pointee))))
                pointer.advance()
            }
            return labels
        }
    }
}
