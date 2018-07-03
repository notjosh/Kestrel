//
//  SearchEngine.swift
//  Blotchy
//
//  Created by Joshua May on 21/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Foundation

@objc class SearchEngine: NSObject {
    @objc dynamic var name: String
    @objc dynamic var template: String

    init(name: String, template: String) {
        self.name = name
        self.template = template

        super.init()
    }

    func url(for searchTerms: String) -> URL? {
        guard let encoded = searchTerms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }

        let string = template
            .replacingOccurrences(of: "{searchTerms}", with: encoded)
            .replacingOccurrences(of: "{inputEncoding?}", with: "UTF-8")
            .replacingOccurrences(of: "{outputEncoding?}", with: "UTF-8")

        return URL(string: string)
    }
}
