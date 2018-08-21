//
//  ContextService.swift
//  Kestrel
//
//  Created by Joshua May on 21/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Cocoa

class ContextService {
    static let shared: ContextService = ContextService()

    static func seed(moc: NSManagedObjectContext) {
        enum SomeColors {
            case royalBlue
            case purple
            case cadburyPurple
            case fushia
            case blush
            case dirtyOrange
            case floridaOrange
            case orangeYello

            var color: NSColor {
                switch self {
                case .royalBlue: return NSColor(red:0.165, green: 0.439, blue: 1.000, alpha: 1.000)
                case .purple: return NSColor(red:0.369, green: 0.459, blue: 0.925, alpha: 1.000)
                case .cadburyPurple: return NSColor(red:0.561, green: 0.490, blue: 0.851, alpha: 1.000)
                case .fushia: return NSColor(red:0.773, green: 0.533, blue: 0.840, alpha: 1.000)
                case .blush: return NSColor(red:0.903, green: 0.510, blue: 0.632, alpha: 1.000)
                case .dirtyOrange: return NSColor(red:0.916, green: 0.556, blue: 0.405, alpha: 1.000)
                case .floridaOrange: return NSColor(red:0.996, green: 0.682, blue: 0.337, alpha: 1.000)
                case .orangeYello: return NSColor(red:1.000, green: 0.772, blue: 0.237, alpha: 1.000)
                }
            }
        }

        guard let searchEngines = try? moc.fetch(NSFetchRequest<SearchEngine>(entityName: SearchEngine.entityName())) else {
            fatalError()
        }

        let contexts = [
            (name: "Swift", searchEngine: searchEngines[1 % searchEngines.count], terms: ["-site:apple.com", "swift"], color: SomeColors.royalBlue.color),
            (name: "objc", searchEngine: searchEngines[1 % searchEngines.count], terms: ["-site:apple.com", "objective-c"], color: SomeColors.purple.color),
            (name: "JavaScript", searchEngine: searchEngines[1 % searchEngines.count], terms: ["javascript"], color: SomeColors.cadburyPurple.color),
            (name: "CSS via SO", searchEngine: searchEngines[2 % searchEngines.count], terms: ["css"], color: SomeColors.fushia.color),
            (name: "(context 4)", searchEngine: searchEngines[3 % searchEngines.count], terms: ["foo", "bar"], color: SomeColors.blush.color),
            (name: "(context 5)", searchEngine: searchEngines[4 % searchEngines.count], terms: ["bar", "baz"], color: SomeColors.dirtyOrange.color),
            (name: "(context 6)", searchEngine: searchEngines[5 % searchEngines.count], terms: ["foo", "bar"], color: SomeColors.floridaOrange.color),
            (name: "(context 7)", searchEngine: searchEngines[6 % searchEngines.count], terms: ["bar", "baz"], color: SomeColors.orangeYello.color),
            (name: "(context 8)", searchEngine: searchEngines[7 % searchEngines.count], terms: ["foo", "bar"], color: SomeColors.royalBlue.color),
            (name: "(context 9)", searchEngine: searchEngines[8 % searchEngines.count], terms: ["bar", "baz"], color: SomeColors.purple.color),
        ]

        for (index, context) in contexts.enumerated() {
            guard let mo = Context.init(managedObjectContext: moc) else {
                return
            }

            mo.order = Int16(index)
            mo.name = context.name
            mo.terms = NSMutableArray(array: context.terms)
            mo.color = context.color
            mo.searchEngine = context.searchEngine

            print(mo)
        }

        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
}
