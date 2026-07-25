import ArgumentParser

@main
struct BrowserctlCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "browserctl",
        abstract: "A utility to manage default browser on macOS",
        // WARN: BuildInfo is generated from a prebuild command build tool plugin
        // See Plugins/BuildInfoPlugin
        version: "browserctl \(BuildInfo.version)",
        subcommands: [
            Get.self,
            Set.self,
            List.self,
            Launch.self,
        ]
    )
}
