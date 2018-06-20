//
//  SearchEngineService.swift
//  Blotchy
//
//  Created by Joshua May on 21/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Foundation

struct SearchEngineService {
    static let shared: SearchEngineService = SearchEngineService()

    let searchEngines: [SearchEngine]

    init() {
        self.init(engines: [
            "duckduckgo.com",
            "google.com",
            "stackoverflow.com",
            ])
    }

    init(engines: [String]) {
        self.searchEngines = engines
            .map { OpenSearch.read(named: $0, bundle: nil) }
            .map { SearchEngine(name: $0.shortName, template: $0.url) }
    }
}
