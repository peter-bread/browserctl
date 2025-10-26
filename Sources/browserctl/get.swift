import ApplicationServices
import ArgumentParser
import Foundation

extension Browserctl {
    struct Get: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Get the default browser"
        )

        @OptionGroup var options: OutputOptions

        mutating func run() throws {

            guard
                let cfURL = LSCopyDefaultApplicationURLForURL(
                    URL(string: "http:")! as CFURL, .all, nil)?.takeRetainedValue()
            else {
                throw NSError(
                    domain: "DefaultBrowser", code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to get default browser"])
            }

            let url = cfURL as URL

            if let bundle = Bundle(url: url) {
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
            } else {
                print(url.path)
            }
        }
    }
}
