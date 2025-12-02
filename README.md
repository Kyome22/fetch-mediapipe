# fetch-mediapipe

This is a tool that obtains the specified version of MediaPipe's XCFrameworks and builds them for Swift Package.

## Usage

```sh
$ brew install cocoapods
$ swift run fm {MediaPipe Version (ex: 0.10.5)}
$ ls -1 Workspace/Frameworks
MediaPipeTasksCommon.xcframework
MediaPipeTasksCommonGraph.xcframework
MediaPipeTasksVision.xcframework
libMediaPipeTasksCommon_device_graph.a
libMediaPipeTasksCommon_simulator_graph.a
```

You can use `MediaPipeTasksCommonGraph.xcframework` & `MediaPipeTasksVision.xcframework` in your swift package.

```swift
// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SomeKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "SomeKit",
            targets: ["SomeKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "MediaPipeTasksCommonGraph",
            path: "XCFrameworks/MediaPipeTasksCommonGraph.xcframework"
        ),
        .binaryTarget(
            name: "MediaPipeTasksVision",
            path: "XCFrameworks/MediaPipeTasksVision.xcframework"
        ),
        .target(
            name: "SomeKit",
            dependencies: [
                "MediaPipeTasksCommonGraph",
                "MediaPipeTasksVision",
            ],
            resources: [
                .process("Resources/face_landmarker.task"),
            ],
            swiftSettings: swiftSettings,
            linkerSettings: [
                .unsafeFlags(["-ObjC"]),
            ]
        ),
    ]
)
```

To actually use MediaPipeTasksVision, you need to download and load a pre-trained model (such as [face_landmarker.task](https://ai.google.dev/edge/mediapipe/solutions/vision/face_landmarker)).
