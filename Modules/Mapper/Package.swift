import PackageDescription

let package = Package(
    name: "Mapper",
    dependencies: [
    	.Package(url: "https://github.com/Zewo/StructuredData.git", majorVersion: 0, minor: 8)
    ]
)
