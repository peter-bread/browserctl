import ArgumentParser

extension Browserctl {
    struct Set: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Set the default browser"
        )

        @Argument(help: "A query that should match the bundle name or ID of the browser")
        var query: String

        mutating func run() async throws {
            try await BrowserManager.setBrowser(query: query)
        }
    }
}
