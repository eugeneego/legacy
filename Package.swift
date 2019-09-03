// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Legacy",
    platforms: [
        .iOS(.v9), .tvOS(.v10), .watchOS(.v3), .macOS(.v10_10),
    ],
    products: [
        .library(name: "Legacy", targets: [ "Legacy" ])
    ],
    dependencies: [],
    targets: [
        .target(name: "Legacy", path: "Sources"),
        .testTarget(name: "LegacyTests", dependencies: [ "Legacy" ], path: "Legacy-iOSTests"),
    ]
)
