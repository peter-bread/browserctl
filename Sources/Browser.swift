import Foundation

struct Browser: Codable {
    let displayName: String?
    let name: String?
    let id: String
    let url: URL
    let isDefault: Bool
    let display: String

    init?(from url: URL, isDefault: Bool) {
        guard
            let bundle = Bundle(url: url),
            let id = bundle.bundleIdentifier
        else {
            return nil
        }

        displayName = bundle.string(key: "CFBundleDisplayName")
        name = bundle.string(key: "CFBundleName")

        // Guarantee that there is some kind of name
        guard let display = displayName ?? name else {
            return nil
        }

        self.display = display
        self.id = id
        self.url = url
        self.isDefault = isDefault
    }
}

extension Browser {
    /// Displays a browser as a string in the given format. If `max` is
    /// provided, the full format will have all names aligned.
    func formatted(as format: BrowserFormat, max: Int? = nil) -> String {
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

typealias Browsers = [Browser]

extension Browsers {
    var `default`: Browser? {
        self.first(where: \.isDefault)
    }

    var jsonData: Data {
        get throws {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(self)
        }
    }

    func outputLines(format: BrowserFormat, withMarker: Bool = true) -> [String] {
        let max = format == .full ? self.map(\.display.count).max() : nil

        return self.map { browser in
            let marker =
                withMarker
                ? "\(browser.isDefault ? "*" : " ") "
                : ""
            return "\(marker)\(browser.formatted(as: format, max: max))"
        }
    }
}

// MARK: - Matching

extension Browser {
    func matchScore(_ query: String) -> Int {
        let terms = [
            id,
            displayName,
            name,
        ].compactMap { $0?.localizedLowercase }

        if terms.contains(query) {
            return 100
        }

        // TODO: Return lower score for partial matches for suggestions
        //
        // Perhaps use Levenshtein distance
        //
        // https://github.com/peter-bread/browserctl/issues/11

        // if terms.contains(where: { $0.hasPrefix(query) }) {
        //     return 50
        // }
        //
        // if terms.contains(where: { $0.contains(query) }) {
        //     return 25
        // }

        return 0
    }
}

extension Browsers {
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

// MARK: - Utils

extension Bundle {
    fileprivate func string(key: String) -> String? {
        infoDictionary?[key] as? String
    }
}
