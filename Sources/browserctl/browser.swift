import Foundation

struct Browser: Codable {
    let name: String
    let id: String
    let url: URL
    let isDefault: Bool
}

extension Browser {
    /// Displays a browser as a string in the given format. If `max` is
    /// provided, the full format will have all names aligned.
    func formatted(as format: BrowserFormat, max: Int? = nil) -> String {
        switch format {
        case .full:
            let name =
                if let max {
                    name.padding(toLength: max, withPad: " ", startingAt: 0)
                } else {
                    name
                }
            return "\(name) (\(id))"

        case .name:
            return name

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

    func outputLines(format: BrowserFormat) -> [String] {
        let max = format == .full ? self.map(\.name.count).max() : nil

        return self.map { browser in
            let marker = browser.isDefault ? "*" : " "
            return "\(marker) \(browser.formatted(as: format, max: max))"
        }
    }
}
