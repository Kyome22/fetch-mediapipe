// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
]

let package = Package(
    name: "fetch-mediapipe",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(
            name: "fm",
            targets: ["FetchMediaPipe"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", exact: "1.6.2"),
    ],
    targets: [
        .executableTarget(
            name: "FetchMediaPipe",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources: [
                .process("Resources/MediaPipeTasksVisionInfo.plist"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)
