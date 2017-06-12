import Venice
import Core

public protocol Media {
    static var mediaType: MediaType { get }
    
    static func encode<T : Encodable>(
        _ value: T,
        to writable: Writable,
        deadline: Deadline
    ) throws
    
    static func decode<T : Decodable>(
        from readable: Readable,
        deadline: Deadline
    ) throws -> T
}

public protocol MediaCodable : Codable {
    static var contentTypes: [Media.Type] { get }
}
