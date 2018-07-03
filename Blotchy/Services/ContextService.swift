//
//  ContextService.swift
//  Blotchy
//
//  Created by Joshua May on 21/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Cocoa

class ContextService {
    static let shared: ContextService = ContextService()

    @objc dynamic var contexts: NSMutableArray

    init() {
        let searchEngines = SearchEngineService.shared.searchEngines

        enum SomeColors {
            case red
            case green
            case blue

            var color: NSColor {
                switch self {
                case .red: return .red
                case .green: return .green
                case .blue: return .blue
                }
            }
        }

        self.contexts = NSMutableArray(array: [
            Context(name: "Swift", searchEngine: searchEngines[1 % searchEngines.count], terms: ["-site:apple.com", "swift"], color: SomeColors.red.color),
            Context(name: "objc", searchEngine: searchEngines[1 % searchEngines.count], terms: ["-site:apple.com", "objective-c"], color: SomeColors.green.color),
            Context(name: "JavaScript", searchEngine: searchEngines[1 % searchEngines.count], terms: ["javascript"], color: SomeColors.blue.color),
            Context(name: "CSS via SO", searchEngine: searchEngines[2 % searchEngines.count], terms: ["css"], color: SomeColors.red.color),
            Context(name: "(context 4)", searchEngine: searchEngines[3 % searchEngines.count], terms: ["foo", "bar"], color: SomeColors.green.color),
            Context(name: "(context 5)", searchEngine: searchEngines[4 % searchEngines.count], terms: ["bar", "baz"], color: SomeColors.blue.color),
            Context(name: "(context 6)", searchEngine: searchEngines[5 % searchEngines.count], terms: ["foo", "bar"], color: SomeColors.red.color),
            Context(name: "(context 7)", searchEngine: searchEngines[6 % searchEngines.count], terms: ["bar", "baz"], color: SomeColors.green.color),
            Context(name: "(context 8)", searchEngine: searchEngines[7 % searchEngines.count], terms: ["foo", "bar"], color: SomeColors.blue.color),
            Context(name: "(context 9)", searchEngine: searchEngines[8 % searchEngines.count], terms: ["bar", "baz"], color: SomeColors.red.color),
        ])
    }
}
