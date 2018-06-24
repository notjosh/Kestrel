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
            Context(name: "Cocoa", searchEngine: searchEngines[0 % searchEngines.count], terms: ["-site:apple.com", "cocoa"]),
            Context(name: "JavaScript", searchEngine: searchEngines[1 % searchEngines.count], terms: ["javascript"]),
            Context(name: "CSS via SO", searchEngine: searchEngines[2 % searchEngines.count], terms: ["css"]),
            Context(name: "(context 4)", searchEngine: searchEngines[3 % searchEngines.count], terms: ["foo", "bar"]),
            Context(name: "(context 5)", searchEngine: searchEngines[4 % searchEngines.count], terms: ["bar", "baz"]),
        ]
    }
}
