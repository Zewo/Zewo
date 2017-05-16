import PackageDescription

let package = Package(
    name: "Zewo",
    targets: [
        Target(name: "CHTTPParser"),
        Target(name: "CYAJL"),
        
        Target(name: "Core", dependencies: ["CYAJL"]),
        Target(name: "IO", dependencies: ["Core"]),
        Target(name: "HTTP", dependencies: ["CHTTPParser", "IO"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/Zewo/Venice.git", majorVersion: 0, minor: 17),
    ]
)
