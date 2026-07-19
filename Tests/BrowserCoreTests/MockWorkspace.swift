import XCTest

@testable import BrowserCore

let safari = Browser(
    id: "com.apple.Safari",
    name: "Safari",
    displayName: "Safari",
    url: URL(string: "file:///Applications/Safari.app")!,
    isDefault: true
)!

let firefox = Browser(
    id: "org.mozilla.firefox",
    name: "Firefox",
    displayName: "Firefox",
    url: URL(string: "file:///Applications/Firefox.app")!,
    isDefault: false
)!

let chrome = Browser(
    id: "com.google.Chrome",
    name: "Chrome",
    displayName: "Google Chrome",
    url: URL(string: "file:///Applications/Google%20Chrome.app")!,
    isDefault: false
)!

struct MockWorkspace: Workspace {
    class State {
        var browsers: [Browser] = []
        var errorToThrow: Error?

        var setDefaultApplicationCalledWith: URL?
        var openApplicationCalledWith: URL?
        var openCalledWith: (url: URL, applicationURL: URL)?
    }

    let state = State()

    func defaultApplication() -> Browser? {
        state.browsers.default
    }

    func applications() -> [Browser] {
        state.browsers
    }

    func setDefaultApplication(at applicationURL: URL) async throws {
        if let error = state.errorToThrow { throw error }
        state.setDefaultApplicationCalledWith = applicationURL
    }

    func openApplication(at url: URL) async throws {
        if let error = state.errorToThrow { throw error }
        state.openApplicationCalledWith = url
    }

    func open(_ url: URL, withApplicationAt applicationURL: URL) async throws {
        if let error = state.errorToThrow { throw error }
        state.openCalledWith = (url, applicationURL)
    }
}
