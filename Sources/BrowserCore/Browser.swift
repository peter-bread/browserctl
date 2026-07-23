import Foundation

/// A browser application, specifically an application for opening 'http:' URLs.
public struct Browser: Codable, Equatable {
    /// Bundle identifier.
    public let id: String
    /// App URL.
    public let url: URL
    /// Whether this is the default browser.
    public let isDefault: Bool
    /// Bundle display name or bundle name.
    public let display: String

    private let displayName: String?
    private let name: String?

    init?(id: String, name: String?, displayName: String?, url: URL, isDefault: Bool) {
        guard let display = displayName ?? name else {
            return nil
        }

        self.id = id
        self.name = name
        self.displayName = displayName
        self.url = url
        self.isDefault = isDefault
        self.display = display
    }
}

extension Browser {
    /// Displays a browser as a string in the given format. If `max` is
    /// provided, the full format will have all names aligned.
    public func formatted(as format: BrowserFormat, max: Int? = nil) -> String {
        switch format {
        case .full:
            let name =
                if let max {
                    display.padding(toLength: max, withPad: " ", startingAt: 0)
                } else {
                    display
                }
            return "\(name) (\(id))"

        case .name:
            return display

        case .id:
            return id
        }
    }
}

extension Array where Element == Browser {
    public var `default`: Browser? {
        self.first(where: \.isDefault)
    }

    public var jsonData: Data {
        get throws {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(self)
        }
    }
}

// MARK: - Matching

extension Browser {
    func matchScore(_ query: String) -> Int {
        // Checking against all three allows all of the following to match:
        //  - 'chrome'
        //  - 'google chrome'
        //  - 'com.google.Chrome'
        let terms = [id, displayName, name].compactMap { $0 }

        if terms.contains(where: { $0.caseInsensitiveCompare(query) == .orderedSame }) {
            return 100
        }

        // TODO: Return lower score for partial matches for suggestions
        //
        // Perhaps use Levenshtein distance
        //
        // https://github.com/peter-bread/browserctl/issues/11

        // if terms.contains(where: { $0.localizedCaseInsensitiveContains(query) }) {
        //     return 50
        // }

        return 0
    }
}

extension Array where Element == Browser {
    func matching(_ query: String) -> [Browser] {
        let query = query.localizedLowercase

        // TODO: Lower threshold to also return suggestions if query
        // doesn't match exactly
        //
        // https://github.com/peter-bread/browserctl/issues/11

        return sorted {
            $0.matchScore(query) > $1.matchScore(query)
        }
        .filter {
            $0.matchScore(query) >= 100
        }
    }
}
