// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Zewo",
    products: [
        .library(name: "Zewo", targets: ["CYAJL", "CHTTPParser", "Core", "IO", "Media", "HTTP", "Zewo"])
    ],
    dependencies: [
        .package(url: "https://github.com/Zewo/CLibdill.git", from: "2.0.0"),
        .package(url: "https://github.com/Zewo/Venice.git", from: "0.20.0"),
        .package(url: "https://github.com/Zewo/CBtls.git", from: "1.1.0"),
        .package(url: "https://github.com/Zewo/CLibreSSL.git", from: "3.1.0"),
    ],
    targets: [
        .target(name: "CYAJL"),
        .target(name: "CHTTPParser"),
        
        .target(name: "Core", dependencies: ["Venice"]),
        .target(name: "IO", dependencies: ["Core"]),
        .target(name: "Media", dependencies: ["Core", "CYAJL"]),
        .target(name: "HTTP", dependencies: ["Media", "IO", "CHTTPParser"]),
        .target(name: "Zewo", dependencies: ["Core", "IO", "Media", "HTTP"]),
        
        .testTarget(name: "CoreTests", dependencies: ["Core"]),
        .testTarget(name: "IOTests", dependencies: ["IO"]),
        .testTarget(name: "MediaTests", dependencies: ["Media"]),
        .testTarget(name: "HTTPTests", dependencies: ["HTTP"]),
    ]
)
