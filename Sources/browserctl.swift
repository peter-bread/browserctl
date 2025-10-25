// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ApplicationServices
import ArgumentParser

@main
struct Browserctl: ParsableCommand {
    @Flag(name: .shortAndLong, help: "Print only the bundle ID")
    var idOnly = false

    @Flag(name: .shortAndLong, help: "Print only the app name")
    var nameOnly = false

    mutating func run() throws {
        guard let cfURL = LSCopyDefaultApplicationURLForURL(URL(string: "http:")! as CFURL, .all, nil)?.takeRetainedValue() else {
            throw NSError(domain: "DefaultBrowser", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get default browser"])
        }

        let url = cfURL as URL

        if let bundle = Bundle(url: url) {
            let info = bundle.infoDictionary ?? [:]
            let name = (info["CFBundleDisplayName"] as? String)
                ?? (info["CFBundleName"] as? String)
                ?? "Unknown"
            let id = bundle.bundleIdentifier ?? "UnknownBundleID"

            if idOnly {
                print(id)
            } else if nameOnly {
                print(name)
            } else {
                print("\(id) (\(name))")
            }
        } else {
            print(url.path)
        }
    }
}
