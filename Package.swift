// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-urlsession-urlloading",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swift-urlsession-urlloading",
            targets: ["swift-urlsession-urlloading"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "swift-urlsession-urlloading"),
        .testTarget(
            name: "swift-urlsession-urlloadingTests",
            dependencies: ["swift-urlsession-urlloading"]),
    ]
)
