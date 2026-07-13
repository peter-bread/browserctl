import AppKit

enum BrowserManager {
    static func all() -> Browsers {
        // TODO: Should these be in Browser.swift and then the isDefault argument
        // removed from the constructor.
        let def = defaultAppURL()
        let urls = availableAppURLs()

        let browsers = urls.compactMap { url in
            return Browser(from: url, isDefault: url == def)
        }

        return browsers
    }

    static func defaultBrowser() -> Browser? {
        return all().default
    }

    static func setBrowser(query: String) async throws {
        let browsers = all()

        // TODO: If one match, use that, else list matches and ask for more specific query
        guard let browser = browsers.matching(query).first else {
            throw BrowserError.noBrowserMatchesQuery(query)
        }

        if browser.isDefault {
            print("\(browser.display) is already the default browser")
            return
        }

        // WARN: This should be fine to force unwrap
        let scheme = http.scheme!

        do {
            try await NSWorkspace.shared.setDefaultApplication(
                at: browser.url, toOpenURLsWithScheme: scheme)
        } catch {
            throw BrowserError.failedToSetBrowser(underlying: error)
        }

        print("Set the default browser to: \(browser.display) (\(browser.id))")
    }
}

// MARK: - Utils

// WARN: This should be fine to force unwrap
private let http = URL(string: "http:")!

/// Returns the URL of the default app to open 'http:' URLs.
private func defaultAppURL() -> URL? {
    return NSWorkspace.shared.urlForApplication(toOpen: http)
}

/// Returns an array of URLs to all available applications that can open 'http:' URLs.
private func availableAppURLs() -> [URL] {
    return NSWorkspace.shared.urlsForApplications(toOpen: http)
}
