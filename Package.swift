// swift-tools-version: 6.1
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
            targets: ["CombineExtensions"])
    ],
    targets: [
        .target(
            name: "CombineExtensions",
            dependencies: []
        ),
        .testTarget(
            name: "CombineExtensionsTests",
            dependencies: [
                .byName(name: "CombineExtensions")
            ]
        )
    ]
)
