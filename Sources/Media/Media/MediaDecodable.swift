public protocol MediaDecodable : Decodable {
    static var decodingMedia: [DecodingMedia.Type] { get }
}

extension MediaDecodable {
    public static var decodingMedia: [DecodingMedia.Type] {
        return [JSON.self]
    }
}

extension MediaDecodable {
    public static func defaultDecodingMedia() throws -> DecodingMedia.Type {
        guard let media = decodingMedia.first else {
            throw MediaCodingError.noDefaultDecodingMedia
        }
        
        return media
    }
    
    public static func decodingMedia(for mediaType: MediaType) throws -> DecodingMedia.Type {
        for media in decodingMedia where media.mediaType.matches(other: mediaType) {
            return media
        }
        
        throw MediaCodingError.unsupportedMediaType
    }
}
