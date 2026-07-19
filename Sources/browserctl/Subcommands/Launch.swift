import ArgumentParser
import BrowserCore
import Foundation

extension BrowserctlCommand {
    struct Launch: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Launch a browser",
            discussion: """
                When no arguments are passed, it opens the default browser. \
                If a valid browser is passed as an argument, that browser is \
                opened. It the --url option is specifed, it will open that URL \
                in the browser.
                """,
            aliases: ["open"]
        )

        @Argument(
            help: "Browser bundle name or ID",
            completion: .custom(BrowserctlCompletions.listBrowserIDsAndNames)
        )
        private var browser: String?

        // TODO: Allow passing multiple URLs
        @Option(
            name: .shortAndLong,
            parsing: .next,
            help: "URL to open",
            transform: {
                guard let url = URL(string: $0) else {
                    throw ValidationError("Invalid URL format: \($0)")
                }
                return url
            }
        )
        private var url: URL?

        // @Option(
        //     name: .shortAndLong,
        //     parsing: .upToNextOption,
        //     transform: {
        //         guard let url = URL(string: $0) else {
        //             throw ValidationError("Invalid URL format: \($0)")
        //         }
        //         return url
        //     })
        // private var url: [URL] = []

        @Flag(
            name: [.long, .customShort("n")],
            help: "Don't actually attempt to open the browser; just print what it would do"
        )
        private var dryRun: Bool = false

        mutating func run() async throws {
            let manager = BrowserManager()
            let target = try manager.resolveBrowser(query: browser)

            if dryRun {
                if let url {
                    print("Would open \(url) in \(target.formatted(as: .full))")
                } else {
                    print("Would open \(target.formatted(as: .full))")
                }
                return
            }

            try await manager.open(browser: target, url: url)
        }
    }
}
