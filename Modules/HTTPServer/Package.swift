import PackageDescription

let package = Package(
    name: "HTTPServer",
    dependencies: [
        .Package(url: "https://github.com/VeniceX/Venice.git", majorVersion: 0, minor: 13),
        .Package(url: "https://github.com/VeniceX/HTTPFile.git", majorVersion: 0, minor: 13),
        .Package(url: "https://github.com/VeniceX/TCP.git", majorVersion: 0, minor: 13),
    ]
)
