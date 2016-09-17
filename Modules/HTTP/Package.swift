import PackageDescription

let package = Package(
    name: "HTTP",
    dependencies: [
        .Package(url: "https://github.com/Zewo/Core.git", majorVersion: 0, minor: 13),
        .Package(url: "https://github.com/Zewo/CHTTPParser.git", majorVersion: 0, minor: 13),
    ]
)
