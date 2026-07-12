import ApplicationServices
import ArgumentParser
import Foundation

extension Browserctl {
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "List all installed browsers"
        )

        @OptionGroup var options: OutputOptions

        @Flag(name: .shortAndLong, help: "Print JSON")
        var json = false

        mutating func run() throws {
            if !json {
                prettyPrint(idOnly: options.idOnly, nameOnly: options.nameOnly)
            } else {
                let data = try printJson()
                print(String(data: data, encoding: .utf8)!)
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
