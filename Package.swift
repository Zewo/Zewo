// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Zewo",
    targets: [
        Target(name: "CYAJL"),
        Target(name: "CHTTPParser"),
        
        Target(name: "Core"),
        Target(name: "IO", dependencies: ["Core"]),
        Target(name: "Content", dependencies: ["CYAJL", "Core"]),
        Target(name: "HTTP", dependencies: ["Content", "IO", "CHTTPParser"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/Zewo/Venice.git", majorVersion: 0, minor: 19),
        .Package(url: "https://github.com/Zewo/CBtls.git", majorVersion: 1),
    ]
)
