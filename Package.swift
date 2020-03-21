// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FortunesAlgorithm",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "FortunesAlgorithm",
            targets: ["FortunesAlgorithm"]
        ),
    ],
    targets: [
        .target(
            name: "FortunesAlgorithm",
            path: "Sources"
        ),
        .testTarget(
            name: "FortunesAlgorithmTests",
            dependencies: ["FortunesAlgorithm"]
        ),
    ]
)


