import AppKit
import ArgumentParser

extension Browserctl {
    struct Launch: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Launch a browser",
            aliases: ["open"]
        )

        @Argument(
            help: "Browser bundle name or ID",
            completion: .custom(BrowserctlCompletions.listBrowserIDsAndNames)
        )
        private var browser: String?

        @Option(name: .shortAndLong, parsing: .next, help: "URL to open")
        private var url: String?

        @Flag(
            name: [.long, .customShort("n")],
            help: "Don't actually attempt to open the browser; just print what it would do"
        )
        private var dryRun: Bool = false

        mutating func run() async throws {
            let target = try resolveBrowser(browser: browser)
            try await openBrowser(target: target, url: url, dryRun: dryRun)
        }
    }
}

private func resolveBrowser(browser: String?) throws -> Browser {
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

private func openBrowser(target: Browser, url: String? = nil, dryRun: Bool = false) async throws {
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
