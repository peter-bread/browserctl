import ApplicationServices
import ArgumentParser
import Foundation

enum XXE: LocalizedError {
    case noDefaultBrowser
}

extension Browserctl {
    struct Get: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Get the default browser"
        )

        @OptionGroup var options: OutputOptions

        mutating func run() throws {

            guard let browser = getDefault() else {
                throw XXE.noDefaultBrowser
            }

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
