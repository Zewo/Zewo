import PackageDescription

let package = Package(
    name: "Zewo",
    dependencies: [
        // HTTP
        .Package(url: "https://github.com/Zewo/HTTPServer.git", majorVersion: 0, minor: 4),
        // .Package(url: "https://github.com/Zewo/HTTPClient.git", majorVersion: 0, minor: 4),
        // .Package(url: "https://github.com/Zewo/HTTPSServer.git", majorVersion: 0, minor: 4),
        // .Package(url: "https://github.com/Zewo/HTTPSClient.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/HTTPFile.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/Router.git", majorVersion: 0, minor: 4),
        // Middleware
        .Package(url: "https://github.com/Zewo/LogMiddleware.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/BasicAuthMiddleware.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/ContentNegotiationMiddleware.git", majorVersion: 0, minor: 4),
        // Media Types
        .Package(url: "https://github.com/Zewo/JSON.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/JSONMediaType.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/URLEncodedForm.git", majorVersion: 0, minor: 4),
        // Base
        .Package(url: "https://github.com/Zewo/Base64.git", majorVersion: 0, minor: 4),
        // .Package(url: "https://github.com/Zewo/OpenSSL.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/ChannelStream.git", majorVersion: 0, minor: 4),
    ]
)
