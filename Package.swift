// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VHX",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "VHX",
            targets: ["VHX"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.92.4"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.3.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "VHX", dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf"),
            ]
        ),
        .testTarget(
            name: "VHXTests",
            dependencies: [
                .target(name: "VHX"),
                .product(name: "XCTVapor", package: "vapor"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf"),
            ],
            resources: [
                .copy("Views"),
            ]
        ),
        .executableTarget(
            name: "Demo",
            dependencies: [
                .target(name: "VHX"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Vapor", package: "vapor"),
            ],
            resources: [
                .copy("Views"),
                .copy("Public"),
            ]
        ),
    ]
)
