//
//  ContextService.swift
//  Blotchy
//
//  Created by Joshua May on 21/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Foundation

struct ContextService {
    static let shared: ContextService = ContextService()

    let contexts: [Context]

    init() {
        let searchEngines = SearchEngineService.shared.searchEngines

        self.contexts = [
            Context(name: "Swift", searchEngine: searchEngines[1 % searchEngines.count], terms: ["-site:apple.com", "swift"]),
            Context(name: "objc", searchEngine: searchEngines[1 % searchEngines.count], terms: ["-site:apple.com", "objective-c"]),
            Context(name: "JavaScript", searchEngine: searchEngines[1 % searchEngines.count], terms: ["javascript"]),
            Context(name: "CSS via SO", searchEngine: searchEngines[2 % searchEngines.count], terms: ["css"]),
            Context(name: "(context 4)", searchEngine: searchEngines[3 % searchEngines.count], terms: ["foo", "bar"]),
            Context(name: "(context 5)", searchEngine: searchEngines[4 % searchEngines.count], terms: ["bar", "baz"]),
            Context(name: "(context 6)", searchEngine: searchEngines[5 % searchEngines.count], terms: ["foo", "bar"]),
            Context(name: "(context 7)", searchEngine: searchEngines[6 % searchEngines.count], terms: ["bar", "baz"]),
            Context(name: "(context 8)", searchEngine: searchEngines[7 % searchEngines.count], terms: ["foo", "bar"]),
            Context(name: "(context 9)", searchEngine: searchEngines[8 % searchEngines.count], terms: ["bar", "baz"]),
        ]
    }
}
