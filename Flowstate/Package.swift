// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Flowstate",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "NLParser", targets: ["NLParser"]),
        .library(name: "Storage", targets: ["Storage"]),
        .library(name: "Features", targets: ["Features"]),
    ],
    targets: [
        // Core modules
        .target(
            name: "DesignSystem",
            path: "Sources/Core/DesignSystem"
        ),
        .target(
            name: "NLParser",
            path: "Sources/Core/NLParser"
        ),
        .target(
            name: "Storage",
            dependencies: ["NLParser"],
            path: "Sources/Core/Storage"
        ),
        .target(
            name: "Features",
            dependencies: ["DesignSystem", "Storage", "NLParser"],
            path: "Sources/Features"
        ),

        // Tests
        .testTarget(
            name: "NLParserTests",
            dependencies: ["NLParser"],
            path: "Tests/CoreTests/NLParserTests"
        ),
        .testTarget(
            name: "StorageTests",
            dependencies: ["Storage"],
            path: "Tests/CoreTests/StorageTests"
        ),
        .testTarget(
            name: "FeatureTests",
            dependencies: ["Features"],
            path: "Tests/FeatureTests"
        ),
    ]
)
