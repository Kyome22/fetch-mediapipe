import Foundation

public struct FetchMediaPipe {
    let derivedDataPath = "${TMPDIR}/DerivedData"
    var version: String
    var outputURL: URL

    var podArchiveURL: URL {
        outputURL.appending(path: "PodArchive")
    }

    var frameworksURL: URL {
        outputURL.appending(path: "Frameworks")
    }

    public init(version: String) {
        self.version = version
        self.outputURL = URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "Workspace")
    }

    public func run() throws {
        try fetchPodArchive()
        try copyStaticLibraries()
        try copyXCFramework(type: .common)
        try copyXCFramework(type: .vision)
        try copyInfoPlist()
        try deleteDerivedData()
        try buildXCFramework()
    }

    func fetchPodArchive() throws {
        let podfileContent = """
            platform :ios, '15.0'
            install! 'cocoapods', :integrate_targets => false
            pod 'MediaPipeTasksVision', '\(version)'
            """

        let output = Shell.run("""
            export LANG=en_US.UTF-8;
            rm -rf \(podArchiveURL.path());
            mkdir \(podArchiveURL.path());
            echo \"\(podfileContent)\" > \(podArchiveURL.appending(path: "Podfile").path());
            $(which pod) update --project-directory=\(podArchiveURL.path())
            """)

        guard output.succeeded else {
            output.printError()
            throw FMError.failedToFetchPodArchive
        }

        print("✅ Fetch Pod Archive")
    }

    func copyStaticLibraries() throws {
        let staticLibrariesURL = podArchiveURL
            .appending(path: "Pods")
            .appending(path: "\(MediaPipeTaskType.common)")
            .appending(path: "frameworks")
            .appending(path: "graph_libraries")

        let output = Shell.run("""
            rm -rf \(frameworksURL.path());
            cp -pfR \(staticLibrariesURL.path()) \(frameworksURL.path())
            """)

        guard output.succeeded else {
            output.printError()
            throw FMError.failedToCopyStaticLibraries
        }

        print("✅ Copy Static Libraries")
    }

    func copyXCFramework(type: MediaPipeTaskType) throws {
        let originalURL = podArchiveURL
            .appending(path: "Pods")
            .appending(path: "\(type)")
            .appending(path: "frameworks")
            .appending(path: "\(type).xcframework")
        let copyURL = frameworksURL
            .appending(path: "\(type).xcframework")

        let output = Shell.run("cp -R \(originalURL.path()) \(copyURL.path())")

        guard output.succeeded else {
            output.printError()
            throw FMError.failedToCopyXCFramework(name: "\(type)")
        }

        print("✅ Copy XCFramework (\(type))")
    }

    func copyInfoPlist() throws {
        let type = MediaPipeTaskType.vision
        guard let url = Bundle.module.url(forResource: "\(type)Info", withExtension: "plist") else {
            throw FMError.notFoundIntoPlist
        }
        let data = try Data(contentsOf: url)

        try ["ios-arm64", "ios-arm64_x86_64-simulator"].forEach { arch in
            let destinationURL = frameworksURL
                .appending(path: "\(type).xcframework")
                .appending(path: arch)
                .appending(path: "\(type).framework")
                .appending(path: "Info.plist")
            try data.write(to: destinationURL)
        }

        print("✅ Copy InfoPlist")
    }

    func deleteDerivedData() throws {
        let output = Shell.run("rm -rf \(derivedDataPath)")

        guard output.succeeded else {
            output.printError()
            throw FMError.failedToDeleteDerivedData
        }

        print("✅ Delete DerivedData")
    }

    func buildXCFramework() throws {
        let type = MediaPipeTaskType.commonGroup
        let projectURL = outputURL
            .appending(path: "\(type).xcodeproj")

        var output = Shell.run("""
            xcodebuild build \
              -project \(projectURL.path()) \
              -scheme \(type) \
              -configuration Release \
              -destination "generic/platform=iOS" \
              -derivedDataPath \(derivedDataPath)
            """)

        guard output.succeeded else {
            output.printError()
            throw FMError.failedToBuildFramework(tag: "iOS")
        }

        print("✅ Build Framework (iOS)")

        output = Shell.run("""
            xcodebuild build \
              -project \(projectURL.path()) \
              -scheme \(type) \
              -configuration Release \
              -destination "generic/platform=iOS Simulator" \
              -derivedDataPath \(derivedDataPath)
            """)

        guard output.succeeded else {
            output.printError()
            throw FMError.failedToBuildFramework(tag: "iOS Simulator")
        }

        print("✅ Build Framework (iOS Simulator)")

        let xcframeworkURL = frameworksURL
            .appending(path: "\(type).xcframework")

        output = Shell.run("""
            xcodebuild -create-xcframework \
              -framework \(derivedDataPath)/Build/Products/Release-iphoneos/\(type).framework \
              -framework \(derivedDataPath)/Build/Products/Release-iphonesimulator/\(type).framework \
              -output \(xcframeworkURL.path())
            """)

        guard output.succeeded else {
            output.printError()
            throw FMError.failedToBuildFramework(tag: "XCFramework")
        }

        print("✅ Build XCFramework")
    }
}
