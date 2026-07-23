import ArgumentParser
import BrowserCore

extension BrowserctlCommand {
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "List all installed browsers"
        )

        @OptionGroup
        private var options: OutputOptions

        @Flag(name: .shortAndLong, help: "Print JSON")
        private var json = false

        @Flag(name: .long, help: "Do not mark default browser")
        private var noMarker = false

        mutating func run() throws {
            let manager = BrowserManager()
            let browsers = manager.browsers()

            if json {
                let data = try browsers.jsonData
                guard let str = String(bytes: data, encoding: .utf8) else {
                    throw BrowserError.couldNotConvertJsonDataToString
                }
                print(str)
                return
            }

            if browsers.isEmpty {
                print("No browsers found")
                return
            }

            let max = options.format == .full ? browsers.map(\.display.count).max() : nil

            for browser in browsers {
                let marker = noMarker ? "" : (browser.isDefault ? "* " : "  ")
                print("\(marker)\(browser.formatted(as: options.format, max: max))")
            }
        }

        mutating func validate() throws {
            if json && (options.idOnly || options.nameOnly || noMarker) {
                throw ValidationError("--json cannot be combined with output formatting options")
            }
        }
    }
}
