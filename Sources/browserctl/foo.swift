import AppKit
import Foundation

// This should be fine to force unwrap
let http = URL(string: "http:")!

/// Returns the URL to the default app to open 'http:' URLs.
func defaultAppUrl() -> URL? {
    return NSWorkspace.shared.urlForApplication(toOpen: http)
}

/// Returns an array of URLs to all available applications that can open 'http:' URLs.
func availableAppUrls() -> [URL] {
    return NSWorkspace.shared.urlsForApplications(toOpen: http)
}

extension Bundle {
    fileprivate func string(key: String) -> String? {
        infoDictionary?[key] as? String
    }
}

func info(for url: URL) -> (name: String, id: String) {
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

typealias Browsers = [Browser]

extension Browsers {
    var `default`: Browser? {
        self.first(where: \.isDefault)
    }
}

func allBrowsers() -> Browsers {
    let def = defaultAppUrl()
    let urls = availableAppUrls()

    let browsers = urls.map { url in
        let (name, id) = info(for: url)
        return Browser(name: name, id: id, url: url, isDefault: url == def)
    }

    return browsers
}

func getDefault() -> Browser? {
    return allBrowsers().default
}

func printJson() throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    return try encoder.encode(allBrowsers())
}

func prettyPrint(idOnly: Bool, nameOnly: Bool) {
    let browsers = allBrowsers()

    let max = browsers.map(\.name.count).max() ?? 0

    for browser in browsers {
        let marker = browser.isDefault ? "*" : " "
        if idOnly {
            print("\(marker) \(browser.id)")
        } else if nameOnly {
            print("\(marker) \(browser.name)")
        } else {
            let paddedName = browser.name.padding(toLength: max, withPad: " ", startingAt: 0)
            print("\(marker) \(paddedName) (\(browser.id))")
        }
    }
}
