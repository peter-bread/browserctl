import ArgumentParser

extension Browserctl {
    struct Set: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Set the default browser"
        )

        @Argument(
            help: "A query that should match the bundle name or ID of the browser",
            completion: .custom(listBrowserIDsAndNames)
        )
        var query: String

        @Flag(
            name: [.long, .customShort("n")],
            help: "Don't actually attempt to set default browser; just print what it would do")
        var dryRun: Bool = false

        mutating func run() async throws {
            try await BrowserManager.setBrowser(query: query, dryRun: dryRun)
        }
    }
}

/// Shell completion.
private func listBrowserIDsAndNames(_ arguments: [String], _ index: Int, _ prefix: String)
    -> [String]
{
    let browsers = BrowserManager.all()

    let ids = browsers.outputLines(format: .id, withMarker: false)
    let names = browsers.outputLines(format: .name, withMarker: false)

    return ids + names
}
