import ArgumentParser
import BrowserCore

extension BrowserctlCommand {
    struct Set: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Set the default browser"
        )

        @Argument(
            help: "Browser bundle name or ID",
            completion: .custom(BrowserctlCompletions.listBrowserIDsAndNames)
        )
        private var browser: String

        @Flag(
            name: [.long, .customShort("n")],
            help: "Don't actually attempt to set default browser; just print what it would do"
        )
        private var dryRun: Bool = false

        mutating func run() async throws {
            let manager = BrowserManager()
            let target = try manager.resolveBrowser(query: browser)

            if dryRun {
                print("Would try to set default browser to \(target.formatted(as: .full))")
                return
            }

            let setResult = try await manager.set(browser: target)

            switch setResult {
            case .changed(to: let browser):
                print("Set the default browser to: \(browser.formatted(as: .full))")
            case .noChange(default: let browser):
                print("Default browser is already set to: \(browser.formatted(as: .full))")
            }
        }
    }
}
