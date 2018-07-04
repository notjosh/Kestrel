//
//  SearchEngineService.swift
//  Blotchy
//
//  Created by Joshua May on 21/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import CoreData

struct SearchEngineService {
    static let shared: SearchEngineService = SearchEngineService()

    static func seed(moc: NSManagedObjectContext) {
        self.seed(moc: moc, engines: [
            "duckduckgo.com",
            "google.com",
            "stackoverflow.com",
			"maps.google.com"
            ])
    }

    static func seed(moc: NSManagedObjectContext, engines: [String]) {
        engines
            .map { OpenSearch.read(named: $0, bundle: nil) }
            .forEach { osd in
                if let se = SearchEngine(managedObjectContext: moc) {
                    se.name = osd.shortName
                    se.template = osd.url
                    se.key = osd.shortName.lowercased()
                }
        }

        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
}
