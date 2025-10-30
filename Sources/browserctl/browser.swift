import AppKit
import ApplicationServices
import Foundation

enum BrowserError: LocalizedError {
    case defaultBrowserNotFound
    case browserNotFound(String)
    case defaultBrowserNotSet(Error)

    var errorDescription: String? {
        switch self {
        case .defaultBrowserNotFound:
            return "Failed to get default browser"
        case .defaultBrowserNotSet(let err):
            return "Failed to set default browser: \(err.localizedDescription)"
        case .browserNotFound(let url):
            return "Could not find browser: \(url)"
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

        let appURL: URL

        if #available(macOS 12.0, *) {
            // Use -[NSWorkspace URLForApplicationToOpenURL:] instead.
            guard let url = NSWorkspace.shared.urlForApplication(toOpen: schemeURL) else {
                throw BrowserError.defaultBrowserNotFound
            }
            appURL = url
        } else {
            guard let unmanaged = LSCopyDefaultApplicationURLForURL(schemeURL as CFURL, .all, nil)
            else {
                throw BrowserError.defaultBrowserNotFound
            }
            appURL = unmanaged.takeRetainedValue() as URL
        }

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

    static func setDefaultBrowser(bundleId: String) async throws {
        let browsers = listAvailableBrowsers()

        // Validate Bundle ID.
        guard let browser = browsers.first(where: { $0.id == bundleId }) else {
            throw BrowserError.browserNotFound(bundleId)
        }

        if #available(macOS 12.0, *) {
            // Use -[NSWorkspace setDefaultApplicationAtURL:toOpenURLsWithScheme:completionHandler:] instead.

            guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)
            else {
                throw BrowserError.browserNotFound(bundleId)
            }

            do {
                try await NSWorkspace.shared.setDefaultApplication(
                    at: appURL, toOpenURLsWithScheme: "http")
            } catch {
                throw BrowserError.defaultBrowserNotSet(error)
            }

        } else {

            try await withCheckedThrowingContinuation { continuation in
                let result = LSSetDefaultHandlerForURLScheme(
                    "http" as CFString, bundleId as CFString)
                if result == noErr {
                    continuation.resume()
                } else {
                    let error = NSError(
                        domain: NSOSStatusErrorDomain,
                        code: Int(result),
                        userInfo: [NSLocalizedDescriptionKey: "Launch Services error \(result)"]
                    )
                    continuation.resume(throwing: BrowserError.defaultBrowserNotSet(error))
                }
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
