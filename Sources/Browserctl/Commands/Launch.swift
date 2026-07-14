import ArgumentParser

extension Browserctl {
    struct Launch: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Launch a browser"
        )

        @Argument(
            help: "Browser bundle name or ID",
            completion: .custom(BrowserctlCompletions.listBrowserIDsAndNames)
        )
        private var browser: String?

        @Option(name: .shortAndLong, parsing: .next)
        private var url: String?

        // TODO: Implement
        mutating func run() async throws {
            print(browser ?? "falling back to default browser")
            print(url ?? "no url")
        }
    }
}
