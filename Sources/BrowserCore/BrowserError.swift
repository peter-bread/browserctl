import Foundation

public enum BrowserError: LocalizedError {
    case noDefaultBrowser
    case failedToSetBrowser(underlying: Error)
    case noBrowserMatchesQuery(String)
    case couldNotConvertJsonDataToString

    public var errorDescription: String? {
        switch self {

        case .noDefaultBrowser:
            return "No default browser"

        case .failedToSetBrowser(let underlying):
            return "Failed to set browser: \(underlying.localizedDescription)"

        case .noBrowserMatchesQuery(let query):
            return "No browser bundle name or ID matches the query: \(query)"

        case .couldNotConvertJsonDataToString:
            return "Could not convert JSON data to String"
        }
    }
}
