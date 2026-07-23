import ArgumentParser
import BrowserCore

extension BrowserctlCommand {
    struct Get: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Get the default browser"
        )

        @OptionGroup
        private var options: OutputOptions

        mutating func run() throws {
            let manager = BrowserManager()
            let browser = try manager.defaultBrowser()
            print(browser.formatted(as: options.format))
        }
    }
}
