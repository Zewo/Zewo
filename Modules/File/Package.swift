import PackageDescription

let package = Package(
    name: "File",
    dependencies: [
        .Package(url: "https://github.com/VeniceX/CLibvenice.git", majorVersion: 0, minor: 13),
        .Package(url: "https://github.com/Zewo/Core.git", majorVersion: 0, minor: 13),
    ]
)
