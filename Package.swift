// swift-tools-version: 5.9
// This is a Swift Package for development, but the app should be
// opened in Xcode as an iOS project.

import PackageDescription

let package = Package(
    name: "FruitPeek",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FruitPeek",
            targets: ["FruitPeek"]
        )
    ],
    targets: [
        .target(
            name: "FruitPeek",
            path: "FruitPeek"
        )
    ]
)
