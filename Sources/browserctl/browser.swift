import AppKit
import Foundation

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

enum BrowserError: LocalizedError {
    case noDefaultBrowser
    case invalidBrowserID(String)
    case failedToSetBrowser(underlying: Error)

    var errorDescription: String? {
        switch self {

        case .noDefaultBrowser:
            return "No default browser"

        case .invalidBrowserID(let id):
            return "Invalid browser id: \(id)"

        case .failedToSetBrowser(let underlying):
            return "Failed to set browser: \(underlying.localizedDescription)"
        }
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

struct Browser: Codable {
    let name: String
    let id: String
    let url: URL
    let isDefault: Bool
}

enum BrowserFormat {
    case full
    case id
    case name

    static func get(idOnly: Bool, nameOnly: Bool) -> BrowserFormat {
        if idOnly {
            return .id
        }

        if nameOnly {
            return .name
        }

        return .full
    }
}

extension Browser {
    /// Displays a browser as a string in the given format. If `max` is
    /// provided, the full format will have all names aligned.
    func formatted(as format: BrowserFormat, max: Int? = nil) -> String {
        switch format {
        case .full:
            let name =
                if let max {
                    name.padding(toLength: max, withPad: " ", startingAt: 0)
                } else {
                    name
                }
            return "\(name) (\(id))"

        case .name:
            return name

        case .id:
            return id
        }
    }
}

typealias Browsers = [Browser]

extension Browsers {
    var `default`: Browser? {
        self.first(where: \.isDefault)
    }

    var jsonData: Data {
        get throws {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(self)
        }
    }

    func outputLines(format: BrowserFormat) -> [String] {
        var lines: [String] = []

        let max = format == .full ? self.map(\.name.count).max() : nil

        for browser in self {
            let marker = browser.isDefault ? "*" : " "
            lines.append("\(marker) \(browser.formatted(as: format, max: max))")
        }

        return lines
    }
}
