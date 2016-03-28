import PackageDescription

let package = Package(
    name: "Zewo",
    dependencies: [
        // HTTP
        .Package(url: "https://github.com/VeniceX/HTTPServer.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/VeniceX/HTTPClient.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/VeniceX/HTTPFile.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/Router.git", majorVersion: 0, minor: 4),
        // Middleware
        .Package(url: "https://github.com/Zewo/RecoveryMiddleware.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/LogMiddleware.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/BasicAuthMiddleware.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/ContentNegotiationMiddleware.git", majorVersion: 0, minor: 4),
        // Media Types
        .Package(url: "https://github.com/Zewo/JSON.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/JSONMediaType.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/URLEncodedForm.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/URLEncodedFormMediaType.git", majorVersion: 0, minor: 4),
        // Other
        .Package(url: "https://github.com/VeniceX/ChannelStream.git", majorVersion: 0, minor: 4),
    ]
)
