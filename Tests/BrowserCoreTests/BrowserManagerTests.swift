import BrowserCore
import XCTest

private struct DummyError: Error, Equatable {}

final class BrowserManagerTests: XCTestCase {
    func testDefaultBrowser() throws {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.browsers = [safari, firefox, chrome]
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        let `default` = try manager.defaultBrowser()

        // Assert
        XCTAssertEqual(`default`.display, "Safari")
    }

    func testDefaultBrowserError() throws {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.errorToThrow = BrowserError.noDefaultBrowser
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        // Assert
        do {
            _ = try manager.defaultBrowser()
            XCTFail("Expected \(BrowserError.noDefaultBrowser)")
        } catch BrowserError.noDefaultBrowser {
            // Success
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testBrowsers() {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.browsers = [safari, firefox, chrome]
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        let browsers = manager.browsers()
        let ids = browsers.compactMap { $0.id }

        // Assert
        XCTAssertEqual(ids, ["com.apple.Safari", "org.mozilla.firefox", "com.google.Chrome"])
    }

    func testBrowsersEmpty() {
        // Arrange
        let mockWorkspace = MockWorkspace()
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        let browsers = manager.browsers()

        // Assert
        XCTAssert(browsers.isEmpty)
    }

    func testResolveBrowserWithNameQuery() throws {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.browsers = [safari, firefox, chrome]
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        let browser = try manager.resolveBrowser(query: "chROmE")

        // Assert
        XCTAssertEqual(browser.id, "com.google.Chrome")
    }

    func testResolveBrowserWithDisplayNameQuery() throws {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.browsers = [safari, firefox, chrome]
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        let browser = try manager.resolveBrowser(query: "GoOgLE chROmE")

        // Assert
        XCTAssertEqual(browser.id, "com.google.Chrome")
    }

    func testResolveBrowserWithIDQuery() throws {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.browsers = [safari, firefox, chrome]
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        let browser = try manager.resolveBrowser(query: "COm.goOgle.ChRome")

        // Assert
        XCTAssertEqual(browser.id, "com.google.Chrome")
    }

    func testResolveBrowserWithNoQuery() throws {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.browsers = [safari, firefox, chrome]
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        let browser = try manager.resolveBrowser(query: nil)

        // Assert
        XCTAssertEqual(browser.id, "com.apple.Safari")
    }

    func testSetToDefault() async throws {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.browsers = [safari, firefox, chrome]
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        let setResult = try await manager.set(browser: safari)

        // Assert
        XCTAssertEqual(setResult, .noChange(default: safari))
    }

    func testSetToOther() async throws {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.browsers = [safari, firefox, chrome]
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        let setResult = try await manager.set(browser: chrome)

        // Assert
        XCTAssertEqual(setResult, .changed(to: chrome))
        XCTAssertEqual(mockWorkspace.state.setDefaultApplicationCalledWith, chrome.url)
    }

    func testSetToOtherError() async throws {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.browsers = [safari, chrome]
        let expectedUnderlyingError = DummyError()
        mockWorkspace.state.errorToThrow = expectedUnderlyingError
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        // Assert
        do {
            _ = try await manager.set(browser: firefox)
            XCTFail(
                "Expected \(BrowserError.failedToSetBrowser(underlying: expectedUnderlyingError))")
        } catch BrowserError.failedToSetBrowser(let underlying) {
            XCTAssertNotNil(underlying)
            XCTAssertEqual(underlying as? DummyError, expectedUnderlyingError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testOpenNoURL() async throws {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.browsers = [safari, chrome]
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        try await manager.open(browser: chrome, url: nil)

        // Assert
        XCTAssertEqual(mockWorkspace.state.openApplicationCalledWith, chrome.url)
    }

    func testOpenNoURLError() async throws {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.browsers = [safari, chrome]
        let expectedError = DummyError()
        mockWorkspace.state.errorToThrow = expectedError
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        // Assert
        do {
            _ = try await manager.open(browser: firefox)
            XCTFail("Expected \(expectedError)")
        } catch is DummyError {
            XCTAssertEqual(mockWorkspace.state.errorToThrow as? DummyError, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testOpenURL() async throws {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.browsers = [safari, chrome]
        let manager = BrowserManager(workspace: mockWorkspace)
        let url = URL(string: "http://google.com")!

        // Act
        try await manager.open(browser: chrome, url: url)

        // Assert
        XCTAssertEqual(mockWorkspace.state.openCalledWith?.applicationURL, chrome.url)
        XCTAssertEqual(mockWorkspace.state.openCalledWith?.url, url)
    }

    func testOpenURLError() async throws {
        // Arrange
        let mockWorkspace = MockWorkspace()
        mockWorkspace.state.browsers = [safari, chrome]
        let expectedError = DummyError()
        mockWorkspace.state.errorToThrow = expectedError
        let manager = BrowserManager(workspace: mockWorkspace)

        // Act
        // Assert
        do {
            _ = try await manager.open(browser: firefox)
            XCTFail("Expected \(expectedError)")
        } catch is DummyError {
            XCTAssertEqual(mockWorkspace.state.errorToThrow as? DummyError, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
