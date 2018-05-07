// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "MongoKittenProvider",
    dependencies: [
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "5.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
    ]
)
