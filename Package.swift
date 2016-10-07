import PackageDescription

let package = Package(
    name: "JWT",
    dependencies: [
        .Package(url: "https://github.com/collinhundley/BlueCryptor.git", majorVersion: 0, minor: 8),
    ]
)
