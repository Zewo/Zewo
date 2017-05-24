import Venice

public protocol Content {
    static var mediaType: MediaType { get }
    static func parse(from readable: Readable, deadline: Deadline) throws -> Self
    func serialize(to writable: Writable, deadline: Deadline) throws
}

public protocol ContentInitializable {
    init(content: Content) throws
}

public protocol ContentRepresentable {
    var content: Content { get }
}
