import ArgumentParser

extension Browserctl {
    struct Set: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Set the default browser"
        )

        @Argument(help: "The bundle identifier of the browser, e.g. com.google.Chrome")
        var bundleId: String

        mutating func run() async throws {
            try await BrowserManager.setBrowser(id: bundleId)
        }
    }
}
