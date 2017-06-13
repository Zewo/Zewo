// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Zewo",
    products: [
        .library(name: "Zewo", targets: ["CYAJL", "CHTTPParser", "Core", "IO", "Media", "HTTP", "Zewo"])
    ],
    dependencies: [
        .package(url: "https://github.com/Zewo/CLibdill.git", .branch("swift-4")),
        .package(url: "https://github.com/Zewo/Venice.git", .branch("swift-4")),
        .package(url: "https://github.com/Zewo/CBtls.git", .branch("swift-4")),
        .package(url: "https://github.com/Zewo/CLibreSSL.git", .branch("swift-4")),
    ],
    targets: [
        .target(name: "CYAJL", dependencies: []),
        .target(name: "CHTTPParser"),
        
        .target(name: "Core", dependencies: ["Venice"]),
        .target(name: "IO", dependencies: ["Core"]),
        .target(name: "Media", dependencies: ["CYAJL", "Core"]),
        .target(name: "HTTP", dependencies: ["Media", "IO", "CHTTPParser"]),
        .target(name: "Zewo", dependencies: ["Core", "IO", "Media", "HTTP"]),

        .testTarget(name: "CoreTests", dependencies: ["Core"]),
        .testTarget(name: "IOTests", dependencies: ["IO"]),
        .testTarget(name: "MediaTests", dependencies: ["Media"]),
        .testTarget(name: "HTTPTests", dependencies: ["HTTP"]),
    ]
)
