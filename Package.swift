// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "browserctl",
    platforms: [
        .macOS("13.0")
    ],
    products: [
        .executable(name: "browserctl", targets: ["browserctl"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.7.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "BrowserCore"),

        .executableTarget(
            name: "browserctl",
            dependencies: [
                "BrowserCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),

        .testTarget(name: "BrowserCoreTests", dependencies: ["BrowserCore"]),

        .testTarget(
            name: "E2ETests",
            dependencies: ["browserctl"]
        ),

        // .testTarget(
        //     name: "IntegrationTests",
        //     dependencies: [
        //         "browserctl",
        //         .product(name: "ArgumentParser", package: "swift-argument-parser"),
        //     ]
        // ),
    ]
)
