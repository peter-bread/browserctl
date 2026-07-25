import PackagePlugin

@main
struct BuildInfoPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let outputDir = context.pluginWorkDirectory
        let generatedFile = outputDir.appending("BuildInfo.swift")

        let scriptPath = context.package.directory.appending([
            "Plugins", "BuildInfoPlugin", "generate.sh",
        ])

        return [
            .prebuildCommand(
                displayName: "Generating BuildInfo.swift with Git tags",
                executable: Path("/bin/sh"),
                arguments: [scriptPath.string, generatedFile.string],
                outputFilesDirectory: outputDir
            )
        ]
    }
}
