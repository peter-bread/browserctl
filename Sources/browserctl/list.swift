import ApplicationServices
import ArgumentParser
import Foundation

extension Browserctl {
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "List all installed browsers"
        )

        @OptionGroup var options: OutputOptions

        mutating func run() {

            let browsers = BrowserService.listAvailableBrowsers()

            for b in browsers {
                if options.idOnly {
                    print(b.id)
                } else if options.nameOnly {
                    print(b.name)
                } else {
                    print("\(b.id) (\(b.name))")
                }
            }
        }

    }
}
