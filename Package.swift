// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Zewo",
    targets: [
        Target(name: "CHTTPParser"),
        Target(name: "CYAJL"),
        Target(name: "CDsock"),
        Target(name: "CArgon2"),
        
        Target(name: "Core"),
        Target(name: "Content", dependencies: ["CYAJL", "Core"]),
        Target(name: "Crypto", dependencies: ["Core", "CArgon2"]),
        Target(name: "IO", dependencies: ["Core", "CDsock"]),
        Target(name: "JWT", dependencies: ["Crypto", "Content"]),
        Target(name: "HTTP", dependencies: ["Content", "IO", "CHTTPParser"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/Zewo/Venice.git", majorVersion: 0, minor: 18),
        .Package(url: "https://github.com/Zewo/COpenSSL.git", majorVersion: 0, minor: 15),
    ]
)
