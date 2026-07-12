import ArgumentParser
import Foundation

extension Browserctl {
    struct Get: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Get the default browser"
        )

        @OptionGroup var options: OutputOptions

        mutating func run() throws {
            guard let browser = BrowserManager.defaultBrowser() else {
                throw BrowserError.noDefaultBrowser
            }

            let format = BrowserFormat.get(idOnly: options.idOnly, nameOnly: options.nameOnly)

            print(browser.formatted(as: format))
        }
    }
}
