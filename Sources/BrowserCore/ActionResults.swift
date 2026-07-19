public enum SetBrowserResult: Equatable {
    case changed(to: Browser)
    case noChange(default: Browser)
}
