// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CombineExtensions",
    platforms: [
        .iOS(.v14),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "CombineExtensions",
            targets: ["CombineExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krogerco/Gauntlet-iOS.git", from: Version(1, 1, 0)),
    ],
    targets: [
        .target(
            name: "CombineExtensions",
            dependencies: []
        ),
        .testTarget(
            name: "CombineExtensionsTests",
            dependencies: [
                .byName(name: "CombineExtensions"),
                .product(name: "Gauntlet", package: "Gauntlet-iOS")
            ]
        ),
    ]
)
