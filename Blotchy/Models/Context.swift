//
//  Context.swift
//  Blotchy
//
//  Created by Joshua May on 21/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Cocoa

@objc class Context: NSObject {
    @objc dynamic var name: String
    @objc dynamic var searchEngine: SearchEngine
    @objc dynamic var terms: [String]
    @objc dynamic var color: NSColor

    // todo: are we using this?
//    let isBranching: Bool

    init(name: String, searchEngine: SearchEngine, terms: [String], color: NSColor) {
        self.name = name
        self.searchEngine = searchEngine
        self.terms = terms
        self.color = color

        super.init()
    }
}

extension Context: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return Context(name: name, searchEngine: searchEngine, terms: terms, color: color)
    }
}
