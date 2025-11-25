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

enum BrowserService {
    static func getDefaultBrowser() throws -> BrowserInfo {
        guard let schemeURL = URL(string: "http:") else {
            throw BrowserError.invalidSchemeURL("http")
        }

        let appURL: URL

        if #available(macOS 12.0, *) {
            // Use -[NSWorkspace URLForApplicationToOpenURL:] instead.
            guard let url = NSWorkspace.shared.urlForApplication(toOpen: schemeURL) else {
                throw BrowserError.noDefaultHandlerForScheme("http")
            }
            appURL = url
        } else {
            guard let unmanaged = LSCopyDefaultApplicationURLForURL(schemeURL as CFURL, .all, nil)
            else {
                throw BrowserError.noDefaultHandlerForScheme("http")
            }
            appURL = unmanaged.takeRetainedValue() as URL
        }

        guard let bundle = Bundle(url: appURL) else {
            throw BrowserError.failedToLoadAppBundle(appURL)
        }

        let (name, id) = bundle.browserInfo

        return BrowserInfo(id: id, name: name, url: appURL)
    }

    /// Returns all browsers that can handle http:// URLs.
    static func listAvailableBrowsers() -> [BrowserInfo] {

        guard let schemeURL = URL(string: "http:") else {
            // TODO: Should this be an error?
            return []
        }

        let urls: [URL]

        if #available(macOS 12.0, *) {
            // Use -[NSWorkspace URLsForApplicationsToOpenURL:] instead.
            urls = NSWorkspace.shared.urlsForApplications(toOpen: schemeURL)
        } else {
            guard let unmanaged = LSCopyApplicationURLsForURL(schemeURL as CFURL, .all)
            else {
                return []
            }
            urls = unmanaged.takeRetainedValue() as? [URL] ?? []
        }

        return urls.compactMap { url in
            guard let bundle = Bundle(url: url) else { return nil }
            let (name, id) = bundle.browserInfo
            return BrowserInfo(id: id, name: name, url: url)
        }
    }

    static func setDefaultBrowser(bundleId: String) async throws {
        let browsers = listAvailableBrowsers()

        // Validate Bundle ID.
        guard let browser = browsers.first(where: { $0.id == bundleId }) else {
            throw BrowserError.browserWithBundleIDNotInstalled(bundleId)
        }

        if #available(macOS 12.0, *) {
            // Use -[NSWorkspace setDefaultApplicationAtURL:toOpenURLsWithScheme:completionHandler:] instead.

            guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)
            else {
                throw BrowserError.browserWithBundleIDNotInstalled(bundleId)
            }

            do {
                try await NSWorkspace.shared.setDefaultApplication(
                    at: appURL, toOpenURLsWithScheme: "http")
            } catch {
                throw BrowserError.defaultBrowserSetFailed(underlying: error)
            }

        } else {

            let result = LSSetDefaultHandlerForURLScheme("http" as CFString, bundleId as CFString)

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
