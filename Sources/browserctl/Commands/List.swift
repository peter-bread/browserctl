import ArgumentParser

extension Browserctl {
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "List all installed browsers"
        )

        @OptionGroup var options: OutputOptions

        @Flag(name: .shortAndLong, help: "Print JSON")
        var json = false

        mutating func run() throws {
            let browsers = BrowserManager.all()

            if json {
                let data = try browsers.jsonData
                print(String(decoding: data, as: UTF8.self))
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

            for line in browsers.outputLines(format: format) {
                print(line)
            }
        }

        mutating func validate() throws {
            if json && (options.idOnly || options.nameOnly) {
                throw ValidationError.init(
                    "option '--json' cannot be used with '--id-only' or '--name-only'")
            }
        }
    }
}
