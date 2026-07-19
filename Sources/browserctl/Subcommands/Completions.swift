import BrowserCore

enum BrowserctlCompletions {
    /// List browser IDs and names combined into a single array.
    @Sendable static func listBrowserIDsAndNames(
        _ arguments: [String], _ index: Int, _ prefix: String
    ) -> [String] {
        let manager = BrowserManager()
        let browsers = manager.browsers()

        let ids = browsers.map { $0.formatted(as: .id) }
        let names = browsers.map { $0.formatted(as: .name) }

        return ids + names
    }
}
