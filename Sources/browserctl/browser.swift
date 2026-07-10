import AppKit
import ApplicationServices
import Foundation

enum BrowserError: LocalizedError {
    case invalidSchemeURL(String)
    case noDefaultHandlerForScheme(String)
    case failedToLoadAppBundle(URL)
    case browserWithBundleIDNotInstalled(String)
    case defaultBrowserSetFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidSchemeURL(let scheme):
            return "Failed to create a URL for scheme '\(scheme)'"

        case .noDefaultHandlerForScheme(let scheme):
            return "No application is registered to handle the '\(scheme)' scheme."

        case .failedToLoadAppBundle(let url):
            return "Unable to load application bundle at: \(url.path)."

        case .browserWithBundleIDNotInstalled(let bundleID):
            return "No installed browser has the bundle identifier '\(bundleID)'."

        case .defaultBrowserSetFailed(let underlying):
            return "Failed to set the default browser: \(underlying.localizedDescription)"
        }
    }
}

struct BrowserInfo {
    let id: String
    let name: String
    let url: URL
}

private enum BrowserScheme {
    static let name = "http"
    static var url: URL {
        URL(string: "\(name):")!
    }
}

enum BrowserService {
    private static func browserInfo(for url: URL) throws -> BrowserInfo {
        guard let bundle = Bundle(url: url) else {
            throw BrowserError.failedToLoadAppBundle(url)
        }

        let (name, id) = bundle.browserInfo

        return BrowserInfo(id: id, name: name, url: url)
    }

    /// Returns the URL to the default application that would be used to open the given URL
    private static func browserURL(for url: URL) -> URL? {
        if #available(macOS 12.0, *) {
            return NSWorkspace.shared.urlForApplication(toOpen: url)
        }
        return LSCopyDefaultApplicationURLForURL(url as CFURL, .all, nil)?.takeRetainedValue()
            as URL?
    }

    private static func browserURLs(for url: URL) -> [URL] {
        if #available(macOS 12.0, *) {
            return NSWorkspace.shared.urlsForApplications(toOpen: url)
        }
        return (LSCopyApplicationURLsForURL(url as CFURL, .all)?.takeRetainedValue() as? [URL])
            ?? []
    }

    static func getDefaultBrowser() throws -> BrowserInfo {
        guard let url = browserURL(for: BrowserScheme.url) else {
            throw BrowserError.failedToLoadAppBundle(BrowserScheme.url)
        }

        return try browserInfo(for: url)
    }

    /// Returns all browsers that can handle http:// URLs.
    static func listAvailableBrowsers() throws -> [BrowserInfo] {
        let urls = browserURLs(for: BrowserScheme.url)

        return try urls.compactMap { url in
            return try browserInfo(for: url)
        }
    }

    static func setDefaultBrowser(bundleId: String) async throws {
        let browsers = try listAvailableBrowsers()

        // Validate Bundle ID.
        guard let browser = browsers.first(where: { $0.id == bundleId }) else {
            throw BrowserError.browserWithBundleIDNotInstalled(bundleId)
        }

        if #available(macOS 12.0, *) {

            guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)
            else {
                throw BrowserError.browserWithBundleIDNotInstalled(bundleId)
            }

            do {
                try await NSWorkspace.shared.setDefaultApplication(
                    at: url, toOpenURLsWithScheme: BrowserScheme.name)
            } catch {
                throw BrowserError.defaultBrowserSetFailed(underlying: error)
            }

        } else {

            let result = LSSetDefaultHandlerForURLScheme(
                BrowserScheme.name as CFString, bundleId as CFString)

            if result != noErr {
                let error = NSError(
                    domain: NSOSStatusErrorDomain,
                    code: Int(result)
                )

                throw BrowserError.defaultBrowserSetFailed(underlying: error)
            }

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
