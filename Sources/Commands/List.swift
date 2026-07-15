import ArgumentParser

extension Browserctl {
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
            let browsers = BrowserManager.all()

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

            let format = BrowserFormat.get(
                idOnly: options.idOnly,
                nameOnly: options.nameOnly
            )

            for line in browsers.outputLines(format: format, withMarker: !noMarker) {
                print(line)
            }
        }

        mutating func validate() throws {
            if json && (options.idOnly || options.nameOnly || noMarker) {
                throw ValidationError.init(
                    "--json cannot be combined with output formatting options"
                )
            }
        }
    }
}
