// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "swift-nebula-client",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "NebulaClient",
            targets: ["NebulaClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OffskyLab/swift-nmtp.git", from: "0.0.1"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.40.0"),
        .package(url: "https://github.com/hirotakan/MessagePacker.git", from: "0.4.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "NebulaClient",
            dependencies: [
                .product(name: "NMTP", package: "swift-nmtp"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "MessagePacker", package: "MessagePacker"),
                .product(name: "Logging", package: "swift-log"),
            ]),
        .testTarget(
            name: "NebulaClientTests",
            dependencies: ["NebulaClient"]),
    ]
)
