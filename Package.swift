// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EasyListView",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "EasyListView", targets: ["EasyListView"])
    ],
    dependencies: [
        .package(url: "https://github.com/moliya/EasyCompatible.git", from: "1.0")
    ],
    targets: [
        .target(name: "EasyListView", dependencies: ["EasyCompatible"], path: "Sources")
    ],
    swiftLanguageVersions: [.v5]
)
