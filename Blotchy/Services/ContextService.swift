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
	
	//let royalBlueColor =  (red:0.165, green: 0.439, blue: 1.000, alpha: 1.000)
    static func seed(moc: NSManagedObjectContext) {
        enum SomeColors {
            case red
            case green
            case blue
			
//			case royalBlue =  UIColor(red:0.165, green: 0.439, blue: 1.000, alpha: 1.000)
//			case  purple =  UIColor(red:0.369, green: 0.459, blue: 0.925, alpha: 1.000)
//			case cadburyPurple =  UIColor(red:0.561, green: 0.490, blue: 0.851, alpha: 1.000)
//			case fushia =  UIColor(red:0.773, green: 0.533, blue: 0.840, alpha: 1.000)
//			case blush =  UIColor(red:0.903, green: 0.510, blue: 0.632, alpha: 1.000)
//			case dirtyOrange =  UIColor(red:0.916, green: 0.556, blue: 0.405, alpha: 1.000)
//			case floridaOrange =  UIColor(red:0.996, green: 0.682, blue: 0.337, alpha: 1.000)
//			case orangeYello =  UIColor(red:1.000, green: 0.772, blue: 0.237, alpha: 1.000)
		

            var color: NSColor {
                switch self {
                case .red: return .red
                case .green: return .green
                case .blue: return .blue
				//case .royalBlue: return royalBlueColor

				}
            }
        }

        guard let searchEngines = try? moc.fetch(NSFetchRequest<SearchEngine>(entityName: SearchEngine.entityName())) else {
            fatalError()
        }

        let contexts = [
            (name: "Swift", searchEngine: searchEngines[1 % searchEngines.count], terms: ["-site:apple.com", "swift"], color: SomeColors.red.color),
            (name: "objc", searchEngine: searchEngines[1 % searchEngines.count], terms: ["-site:apple.com", "objective-c"], color: SomeColors.green.color),
            (name: "JavaScript", searchEngine: searchEngines[1 % searchEngines.count], terms: ["javascript"], color: SomeColors.blue.color),
            (name: "CSS via SO", searchEngine: searchEngines[2 % searchEngines.count], terms: ["css"], color: SomeColors.red.color),
            (name: "Plain Google", searchEngine: searchEngines[1 % searchEngines.count], terms: [], color: SomeColors.green.color),
            (name: "(context 5)", searchEngine: searchEngines[4 % searchEngines.count], terms: ["bar", "baz"], color: SomeColors.blue.color),

        ]

        contexts.forEach { context in
            guard let mo = Context.init(managedObjectContext: moc) else {
                return
            }

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
