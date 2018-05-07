import PackageDescription

let package = Package(
    name: "MongoKittenProvider",
    dependencies: [
        .Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 5, minor: 0),
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 3),
    ]
)
