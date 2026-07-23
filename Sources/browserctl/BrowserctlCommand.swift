import ArgumentParser

@main
struct BrowserctlCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "browserctl",
        abstract: "A utility to manage default browser on macOS",
        subcommands: [
            Get.self,
            Set.self,
            List.self,
            Launch.self,
        ]
    )
}
