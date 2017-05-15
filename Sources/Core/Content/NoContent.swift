public struct NoContent {
    public init() {}
}

extension NoContent : ContentInitializable {
    public init(content: Content) throws {}
}
