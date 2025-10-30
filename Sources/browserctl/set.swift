import ApplicationServices
import ArgumentParser
import Foundation

extension Browserctl {
    struct Set: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Set the default browser"
        )

        @Argument(help: "The bundle identifier of the browser, e.g. com.google.Chrome")
        var bundleId: String

        mutating func run() throws {
            try BrowserService.setDefaultBrowser(bundleId: bundleId)
        }
    }
}
