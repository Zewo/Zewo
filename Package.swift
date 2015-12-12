import PackageDescription

let package = Package(
	name: "Epoch",
	dependencies: [
		.Package(url: "https://github.com/Zewo/HTTPParser.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/Venice.git", majorVersion: 0, minor: 1)
	]
)
