import AppKit

/// Concrete Workspace using NSWorkspace to interact with the system.
public struct SystemWorkspace: Workspace {
    public init() {}

    private let http = URL(string: "http:")!

    private func makeBrowser(from url: URL, isDefault: Bool) -> Browser? {
        guard
            let bundle = Bundle(url: url),
            let id = bundle.bundleIdentifier
        else {
            return nil
        }

        return Browser(
            id: id,
            name: bundle.string(key: "CFBundleName"),
            displayName: bundle.string(key: "CFBundleDisplayName"),
            url: url,
            isDefault: isDefault
        )
    }

    public func defaultApplication() -> Browser? {
        guard let appURL = NSWorkspace.shared.urlForApplication(toOpen: http) else {
            return nil
        }

        return makeBrowser(from: appURL, isDefault: true)
    }

    /// Returns list of available browsers, excluding those found in cache directories.
    public func applications() -> [Browser] {
        let `default` = defaultApplication()

        let caches = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask)

        // TODO: Handle duplicates
        // Maybe `Set(NSWorkspace.shared.urlsForApplications(toOpen: http))`

        return NSWorkspace.shared.urlsForApplications(toOpen: http).filter { url in
            !caches.contains { cache in url.standardizedFileURL.path().hasPrefix(cache.path()) }
        }.compactMap {
            makeBrowser(from: $0, isDefault: $0 == `default`?.url)
        }
    }

    public func setDefaultApplication(at applicationURL: URL) async throws {
        try await NSWorkspace.shared.setDefaultApplication(
            at: applicationURL, toOpenURLsWithScheme: http.scheme!)
    }

    public func openApplication(at url: URL) async throws {
        // https://developer.apple.com/documentation/appkit/nsworkspace#Launching-and-Hiding-Apps
        try await NSWorkspace.shared.openApplication(
            at: url,
            configuration: .init()
        )
    }

    public func open(_ url: URL, withApplicationAt applicationURL: URL) async throws {
        // https://developer.apple.com/documentation/appkit/nsworkspace#Opening-URLs
        try await NSWorkspace.shared.open(
            [url],
            withApplicationAt: applicationURL,
            configuration: .init()
        )
    }
}

extension Bundle {
    fileprivate func string(key: String) -> String? {
        infoDictionary?[key] as? String
    }
}
