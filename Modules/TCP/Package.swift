import PackageDescription

let package = Package(
    name: "TCP",
    dependencies: [
        .Package(url: "https://github.com/VeniceX/IP.git", majorVersion: 0, minor: 13),
        .Package(url: "https://github.com/VeniceX/Venice.git", majorVersion: 0, minor: 13),
        .Package(url: "https://github.com/Zewo/OpenSSL.git", majorVersion: 0, minor: 13),
    ]
)
