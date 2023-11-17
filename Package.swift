// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SmilesLocationHandler",
    platforms: [
        .iOS(.v13)
    ], products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SmilesLocationHandler",
            targets: ["SmilesLocationHandler"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/smilesiosteam/SmilesEasyTipView.git", branch: "main"),
        .package(url: "https://github.com/smilesiosteam/SmilesUtilities.git", branch: "main"),
        .package(url: "https://github.com/smilesiosteam/NetworkingLayer.git", branch: "main"),
        .package(url: "https://github.com/smilesiosteam/SmilesAnalytics.git", branch: "main"),
        .package(url: "https://github.com/smilesiosteam/SmilesBaseMainRequest.git", branch: "main"),
        .package(url: "https://github.com/smilesiosteam/SmilesLanguageManager.git", branch: "main"),
        .package(url: "https://github.com/YAtechnologies/GoogleMaps-SP.git", .upToNextMinor(from: "7.2.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SmilesLocationHandler",
            dependencies: [
                .product(name: "SmilesEasyTipView", package: "SmilesEasyTipView"),
                .product(name: "SmilesUtilities", package: "SmilesUtilities"),
                .product(name: "NetworkingLayer", package: "NetworkingLayer"),
                .product(name: "AnalyticsSmiles", package: "SmilesAnalytics"),
                .product(name: "SmilesBaseMainRequestManager", package: "SmilesBaseMainRequest"),
                .product(name: "SmilesLanguageManager", package: "SmilesLanguageManager"),
                .product(name: "GoogleMaps", package: "GoogleMaps-SP")
            ],
            resources: [
                .process("Resources")
            ])
    ]
)
