import Foundation

enum BrowserError: LocalizedError {
    case noDefaultBrowser
    case invalidBrowserID(String)
    case failedToSetBrowser(underlying: Error)

    var errorDescription: String? {
        switch self {

        case .noDefaultBrowser:
            return "No default browser"

        case .invalidBrowserID(let id):
            return "Invalid browser id: \(id)"

        case .failedToSetBrowser(let underlying):
            return "Failed to set browser: \(underlying.localizedDescription)"
        }
    }
}
