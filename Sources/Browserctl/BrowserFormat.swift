enum BrowserFormat {
    case full
    case id
    case name

    /// Gets the format a browser should be displayed with.
    ///
    /// Assumes that idOnly and nameOnly are not both true -- this should be
    /// prevented with the validate function for the CLI.
    static func get(idOnly: Bool, nameOnly: Bool) -> BrowserFormat {
        if idOnly {
            return .id
        }

        if nameOnly {
            return .name
        }

        return .full
    }
}
