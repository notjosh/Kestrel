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
            Context(name: "context a", searchEngine: searchEngines[0 % searchEngines.count], terms: ["foo", "bar"]),
            Context(name: "context b", searchEngine: searchEngines[1 % searchEngines.count], terms: ["baz", "qux"]),
            Context(name: "context c", searchEngine: searchEngines[2 % searchEngines.count], terms: ["milk", "shake", "duck"]),
            Context(name: "context d", searchEngine: searchEngines[3 % searchEngines.count], terms: []),
            Context(name: "context e", searchEngine: searchEngines[4 % searchEngines.count], terms: ["oh", "when", "the", "saints"]),
        ]
    }
}
