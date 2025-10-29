import ApplicationServices
import ArgumentParser
import Foundation

extension Browserctl {
    struct Get: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Get the default browser"
        )

        @OptionGroup var options: OutputOptions

        mutating func run() throws {

            let browser = try BrowserService.getDefaultBrowser()

            if options.idOnly {
                print(browser.id)
            } else if options.nameOnly {
                print(browser.name)
            } else {
                print("\(browser.id) (\(browser.name))")
            }

        }
    }
}
