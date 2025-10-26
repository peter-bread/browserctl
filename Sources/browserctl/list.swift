import ApplicationServices
import ArgumentParser
import Foundation

extension Browserctl {
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "List all installed browsers"
        )

        @OptionGroup var options: OutputOptions

        mutating func run() {
            let appURLs =
                LSCopyApplicationURLsForURL(URL(string: "http:")! as CFURL, .all)?
                .takeRetainedValue() as? [URL] ?? []

            if appURLs.isEmpty {
                print("No browsers found")
                return
            }

            for url in appURLs {
                guard let bundle = Bundle(url: url) else { continue }
                let info = bundle.infoDictionary ?? [:]
                let name =
                    (info["CFBundleDisplayName"] as? String)
                    ?? (info["CFBundleName"] as? String)
                    ?? "Unknown"
                let id = bundle.bundleIdentifier ?? "UnknownBundleID"

                if options.idOnly {
                    print(id)
                } else if options.nameOnly {
                    print(name)
                } else {
                    print("\(id) (\(name))")
                }
            }
        }
    }
}
