import AppKit

enum BrowserManager {
    static func all() -> Browsers {
        let def = defaultAppURL()
        let urls = availableAppURLs()

        let browsers = urls.map { url in
            let (name, id) = bundleInfo(for: url)
            return Browser(name: name, id: id, url: url, isDefault: url == def)
        }

        return browsers
    }

    static func defaultBrowser() -> Browser? {
        return all().default
    }

    static func setBrowser(id: String) async throws {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: id) else {
            throw BrowserError.invalidBrowserID(id)
        }

        // WARN: This should be fine to force unwrap
        let scheme = http.scheme!

        do {
            try await NSWorkspace.shared.setDefaultApplication(
                at: url, toOpenURLsWithScheme: scheme)
        } catch {
            throw BrowserError.failedToSetBrowser(underlying: error)
        }

        let browser = bundleInfo(for: url)

        print("Set the default browser to: \(browser.name) (\(browser.id))")
    }
}

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

extension Bundle {
    fileprivate func string(key: String) -> String? {
        infoDictionary?[key] as? String
    }
}

private func bundleInfo(for url: URL) -> (name: String, id: String) {
    guard let bundle = Bundle(url: url) else {
        return ("Unknown", "Unknown")
    }

    let name =
        bundle.string(key: "CFBundleDisplayName")
        ?? bundle.string(key: "CFBundleName")
        ?? "Unknown"

    let id =
        bundle.bundleIdentifier
        ?? "Unknown"

    return (name, id)
}
