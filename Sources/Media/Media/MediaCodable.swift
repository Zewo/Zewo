public typealias MediaCodable = MediaEncodable & MediaDecodable

public enum MediaCodingError : Error {
    case noDefaultEncodingMedia
    case noDefaultDecodingMedia
    case unsupportedMediaType
}

extension MediaCodingError : CustomStringConvertible {
    public var description: String {
        switch self {
        case .noDefaultEncodingMedia:
            return "No default encoding media."
        case .noDefaultDecodingMedia:
            return "No default decoding media."
        case .unsupportedMediaType:
            return "Unsupported media type."
        }
    }
}
