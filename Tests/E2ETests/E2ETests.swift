import XCTest

import class Foundation.Bundle

final class E2ETests: XCTestCase {
    var productsDirectory: URL {
        #if os(macOS)
            for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
                return bundle.bundleURL.deletingLastPathComponent()
            }
            fatalError("couldn't find the products directory")
        #else
            return Bundle.main.bundleURL
        #endif
    }

    func testHelpCommandOutputsUsageAndExitsSuccessfully() throws {
        let binaryExecutableURL = productsDirectory.appendingPathComponent("browserctl")
        let process = Process()
        process.executableURL = binaryExecutableURL

        process.arguments = ["--help"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertEqual(process.terminationStatus, 0)
        XCTAssertTrue(output.contains("USAGE: browserctl"), "Expected help text but got: \(output)")
    }
}
