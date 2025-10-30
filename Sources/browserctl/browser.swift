import ApplicationServices
import Foundation

enum BrowserError: LocalizedError {
    case defaultBrowserNotFound
    case browserNotFound
    case defaultBrowserNotSet

    var errorDescription: String? {
        switch self {
        case .defaultBrowserNotFound:
            return "Failed to get default browser"
        case .defaultBrowserNotSet:
            return "Failed to set default browser"
        case .browserNotFound:
            return "Could not find browser"
        }
    }
}

struct BrowserInfo {
    let id: String
    let name: String
    let url: URL
}

enum BrowserService {
    static func getDefaultBrowser() throws -> BrowserInfo {
        guard let schemeURL = URL(string: "http:") else {
            throw BrowserError.defaultBrowserNotFound
        }

        guard let unmanaged = LSCopyDefaultApplicationURLForURL(schemeURL as CFURL, .all, nil)
        else {
            throw BrowserError.defaultBrowserNotFound
        }

        let appURL = unmanaged.takeRetainedValue() as URL

        guard let bundle = Bundle(url: appURL) else {
            throw BrowserError.defaultBrowserNotFound
        }

        let (name, id) = bundle.browserInfo

        return BrowserInfo(id: id, name: name, url: appURL)
    }

    /// Returns all browsers that can handle http:// URLs.
    static func listAvailableBrowsers() -> [BrowserInfo] {
        guard let schemeURL = URL(string: "http:"),
            let unmanaged = LSCopyApplicationURLsForURL(schemeURL as CFURL, .all)
        else {
            return []
        }

        let urls = unmanaged.takeRetainedValue() as? [URL] ?? []
        return urls.compactMap { url in
            guard let bundle = Bundle(url: url) else { return nil }
            let (name, id) = bundle.browserInfo
            return BrowserInfo(id: id, name: name, url: url)
        }
    }

    static func setDefaultBrowser(bundleId: String) throws {
        let browsers = listAvailableBrowsers()

        guard let browser = browsers.first(where: { $0.id == bundleId }) else {
            throw BrowserError.browserNotFound
        }

        let result = LSSetDefaultHandlerForURLScheme("http" as CFString, bundleId as CFString)
        if result != noErr {
            throw BrowserError.defaultBrowserNotSet
        }

        print("Default browser set to \(browser.name) (\(browser.id))")

    }
}

extension Bundle {
    /// Human-readable app name and bundle ID with sensible fallbacks.
    var browserInfo: (name: String, id: String) {
        let info = infoDictionary ?? [:]
        let name =
            (info["CFBundleDisplayName"] as? String)
            ?? (info["CFBundleName"] as? String)
            ?? "Unknown"
        let id = bundleIdentifier ?? "UnknownBundleID"
        return (name, id)
    }
}
