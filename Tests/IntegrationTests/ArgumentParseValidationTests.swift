import ArgumentParser
import XCTest

@testable import browserctl

// TODO: Might remove these tests -- currently this is not a test target.

final class ArgumentParseValidationTests: XCTestCase {
    func testListIDOnlyAndNameOnlyFlagsThrowsValidationError() {
        // Arrange
        let args = ["list", "--id-only", "--name-only"]

        // Act
        // Assert
        do {
            _ = try BrowserctlCommand.parseAsRoot(args)
            XCTFail("Expected parsing to fail due to mutually exclusive flags")
        } catch {
            let msg = BrowserctlCommand.message(for: error)
            XCTAssertTrue(msg.contains("mutually exclusive"))
        }
    }

    func testListJSONFlagCombinedWithIDOnlyThrowsValidationError() {
        // Arrange
        let arguments = ["list", "--json", "--id-only"]

        // Act
        // Assert
        do {
            _ = try BrowserctlCommand.parseAsRoot(arguments)
            XCTFail("Expected parsing to fail.")
        } catch {
            let message = BrowserctlCommand.message(for: error)
            XCTAssertTrue(message.contains("--json cannot be combined"))
        }
    }
}
