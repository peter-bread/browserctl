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
            try await BrowserManager.launch(browser: browser, url: url, dryRun: dryRun)
        }
    }
}
