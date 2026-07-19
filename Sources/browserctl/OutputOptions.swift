import ArgumentParser
import BrowserCore

/// Options for how browser information should be displayed to the user.
/// Mainly useful for scripting & automation.
struct OutputOptions: ParsableArguments {
    @Flag(name: .shortAndLong, help: "Print only the bundle ID")
    var idOnly = false

    @Flag(name: .shortAndLong, help: "Print only the app name")
    var nameOnly = false

    mutating func validate() throws {
        if idOnly && nameOnly {
            throw ValidationError("options '--id-only' and '--name-only' are mutually exclusive")
        }
    }
}

extension OutputOptions {
    var format: BrowserFormat {
        if idOnly { return .id }
        if nameOnly { return .name }
        return .full
    }
}
