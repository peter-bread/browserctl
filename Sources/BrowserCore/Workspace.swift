import AppKit

/// A workspace to get and set system browser information, as well as launch browser applications.
public protocol Workspace {
    func defaultApplication() -> Browser?

    func applications() -> [Browser]

    func setDefaultApplication(at applicationURL: URL) async throws

    func openApplication(at url: URL) async throws

    func open(_ url: URL, withApplicationAt applicationURL: URL) async throws
}
