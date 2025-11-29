import ArgumentParser
import FetchMediaPipeCore

struct FM: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "fm",
        abstract: "Extract the specified version of XCFramework from MediaPipe.",
        version: "0.0.1"
    )

    @Argument(help: "The version of MediaPipe.")
    var version: String

    mutating func run() throws {
        try FetchMediaPipe(version: version).run()
    }
}

FM.main()
