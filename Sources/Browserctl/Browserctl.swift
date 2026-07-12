import ArgumentParser

@main
struct Browserctl: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility to manage default browser on MacOS",
        subcommands: [
            Get.self,
            Set.self,
            List.self,
        ]
    )
}

/// Options for how browser information should be displayed to the user.
/// Mainly useful for scripting & automation.
struct OutputOptions: ParsableArguments {
    @Flag(name: .shortAndLong, help: "Print only the bundle ID")
    var idOnly = false

    @Flag(name: .shortAndLong, help: "Print only the app name")
    var nameOnly = false

    mutating func validate() throws {
        if idOnly && nameOnly {
            throw ValidationError.init(
                "options '--id-only' and '--name-only' are mutually exclusive")
        }
    }
}
