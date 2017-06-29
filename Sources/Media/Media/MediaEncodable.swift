public protocol MediaEncodable : Encodable {
    static var encodingMedia: [EncodingMedia.Type] { get }
}

extension MediaEncodable {
    public static var encodingMedia: [EncodingMedia.Type] {
        return [JSON.self]
    }
}

extension MediaEncodable {
    public static func defaultEncodingMedia() throws -> EncodingMedia.Type {
        guard let media = encodingMedia.first else {
            throw MediaCodingError.noDefaultEncodingMedia
        }
        
        return media
    }
    
    public static func encodingMedia(for mediaType: MediaType) throws -> EncodingMedia.Type {
        for media in encodingMedia where media.mediaType.matches(other: mediaType) {
            return media
        }
        
        throw MediaCodingError.unsupportedMediaType
    }
}
