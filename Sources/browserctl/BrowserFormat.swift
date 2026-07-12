enum BrowserFormat {
    case full
    case id
    case name

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
