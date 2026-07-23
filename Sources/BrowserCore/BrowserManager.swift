import Foundation

public struct BrowserManager {
    private let workspace: Workspace

    public init(workspace: Workspace = SystemWorkspace()) {
        self.workspace = workspace
    }

    public func browsers() -> [Browser] {
        workspace.applications()
    }

    public func defaultBrowser() throws -> Browser {
        // guard let browser = browsers().default else {
        guard let browser = workspace.defaultApplication() else {
            throw BrowserError.noDefaultBrowser
        }
        return browser
    }

    public func resolveBrowser(query: String?) throws -> Browser {
        // TODO: If one match, use that, else list matches and ask for more specific query
        // TODO: Handle multiple browsers with the same name or ID stored at different URLs
        if let query {
            guard let requested = browsers().matching(query).first else {
                throw BrowserError.noBrowserMatchesQuery(query)
            }
            return requested
        } else {
            return try defaultBrowser()
        }
    }

    public func set(browser: Browser) async throws -> SetBrowserResult {
        if browser.isDefault {
            return .noChange(default: browser)
        }

        do {
            try await workspace.setDefaultApplication(at: browser.url)
            return .changed(to: browser)
        } catch {
            throw BrowserError.failedToSetBrowser(underlying: error)
        }
    }

    public func open(browser: Browser, url: URL? = nil) async throws {
        if let url {
            try await workspace.open(url, withApplicationAt: browser.url)
        } else {
            try await workspace.openApplication(at: browser.url)
        }
    }
}
