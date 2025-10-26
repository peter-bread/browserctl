import ApplicationServices
import ArgumentParser
import Foundation

extension Browserctl {
    struct Set: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Set the default browser"
        )

        @Argument(help: "The bundle identifier of the browser, e.g. com.google.Chrome")
        var bundleId: String

        mutating func run() {
            let appURLs =
                LSCopyApplicationURLsForURL(URL(string: "http:")! as CFURL, .all)?
                .takeRetainedValue() as? [URL] ?? []

            let bundles = appURLs.compactMap { url -> (String, URL)? in
                guard let bundle = Bundle(url: url),
                    let id = bundle.bundleIdentifier
                else { return nil }
                return (id, url)
            }

            guard let target = bundles.first(where: { $0.0 == bundleId }) else {
                print("Error: No browser found with bundle ID '\(bundleId)'")
                return
            }

            LSSetDefaultHandlerForURLScheme("http" as CFString, bundleId as CFString)
            LSSetDefaultHandlerForURLScheme("https" as CFString, bundleId as CFString)

            print("✅ Set default browser to \(bundleId) (\(target.1.lastPathComponent))")
        }
    }
}
