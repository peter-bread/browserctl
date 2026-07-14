enum BrowserctlCompletions {

    /// List browser IDs and names combined into a single array.
    static func listBrowserIDsAndNames(_ arguments: [String], _ index: Int, _ prefix: String)
        -> [String]
    {
        let browsers = BrowserManager.all()

        let ids = browsers.outputLines(format: .id, withMarker: false)
        let names = browsers.outputLines(format: .name, withMarker: false)

        return ids + names
    }
}
