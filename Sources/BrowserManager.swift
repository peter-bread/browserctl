import AppKit

enum BrowserManager {
    static func all() -> Browsers {
        // TODO: Should these be in Browser.swift and then the isDefault argument
        // removed from the constructor.
        let def = defaultAppURL()
        let urls = availableAppURLs()

        let browsers = urls.compactMap { url in
            Browser(from: url, isDefault: url == def)
        }

        return browsers
    }

    static func defaultBrowser() -> Browser? {
        return all().default
    }

    static func setBrowser(query: String, dryRun: Bool = false) async throws {
        let browsers = all()

        // TODO: If one match, use that, else list matches and ask for more specific query
        guard let browser = browsers.matching(query).first else {
            throw BrowserError.noBrowserMatchesQuery(query)
        }

        if browser.isDefault {
            print("\(browser.display) is already the default browser")
            return
        }

        if dryRun {
            print("Would try to set default browser to: \(browser.display) (\(browser.id))")
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

        print("Set the default browser to: \(browser.formatted(as: .full))")
    }

    static func launch(browser: String?, url: String?, dryRun: Bool) async throws {
        let target = try resolveBrowser(browser: browser)
        try await openBrowser(target: target, url: url, dryRun: dryRun)
    }

    private static func resolveBrowser(browser: String?) throws -> Browser {
        if let browser {
            guard let requested = BrowserManager.all().matching(browser).first else {
                throw BrowserError.noBrowserMatchesQuery(browser)
            }
            return requested
        } else {
            guard let `default` = BrowserManager.defaultBrowser() else {
                throw BrowserError.noDefaultBrowser
            }
            return `default`
        }
    }

    private static func openBrowser(target: Browser, url: String? = nil, dryRun: Bool = false)
        async throws
    {
        // Customise how the browser is opened
        //
        // https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration
        let config = NSWorkspace.OpenConfiguration()

        if let url {
            guard let url = URL(string: url) else {
                throw BrowserError.couldNotConstructURL(url)
            }

            if dryRun {
                print("Would open \(url) in \(target.formatted(as: .full))")
                return
            }

            // https://developer.apple.com/documentation/appkit/nsworkspace#Opening-URLs
            try await NSWorkspace.shared.open(
                [url], withApplicationAt: target.url, configuration: config)

        } else {

            if dryRun {
                print("Would open \(target.formatted(as: .full))")
                return
            }

            // https://developer.apple.com/documentation/appkit/nsworkspace#Launching-and-Hiding-Apps
            try await NSWorkspace.shared.openApplication(at: target.url, configuration: config)
        }
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
