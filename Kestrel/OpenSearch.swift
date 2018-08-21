//
//  OpenSearch.swift
//  Kestrel
//
//  Created by Joshua May on 20/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Foundation
import SWXMLHash

struct OpenSearchDescription {
    var shortName: String { return indexer["OpenSearchDescription"]["ShortName"].element!.text }
    var longName: String { return indexer["OpenSearchDescription"]["LongName"].element!.text }
    var description: String { return indexer["OpenSearchDescription"]["Description"].element!.text }
    var tags: [String] { return tagsText.split(separator: " ").map { String($0)} }
    var contact: String { return indexer["OpenSearchDescription"]["Contact"].element!.text }
    var url: String {
        if let url = urls["application/atom+xml"] {
            return url
        }

        if let url = urls["application/rss+xml"] {
            return url
        }

        if let url = urls["text/xml"] {
            return url
        }

        if let url = urls["text/html"] {
            return url
        }

        return urls.first!.value
    }

    // todo:
    //    var images: String
    //    var developer: String
    //    var query: String
    //    var attribution: String
    //    var syndicationRight: String
    //    var adultContent: Bool
    //    var language: String
    //    var outputEncoding: String
    //    var inputEncoding: String

    var tagsText: String { return indexer["OpenSearchDescription"]["Tags"].element!.text }
    var urls: [String: String] {
        let xmls = indexer["OpenSearchDescription"]["Url"].all

        // todo: nice map() implementation version of this, eh
        var urls = [String: String]()
        for node in xmls {
            guard
                let type = node.element?.attribute(by: "type")?.text,
                let template = node.element?.attribute(by: "template")?.text
                else {
                    continue
            }

            urls[type] = template
        }

        return urls
    }

    var xml: String { return indexer.description }

    fileprivate let indexer: XMLIndexer

    init(indexer: XMLIndexer) {
        self.indexer = indexer
    }
}

struct OpenSearch {
    static func read(named filename: String, bundle: Bundle?) -> OpenSearchDescription {
        let url = (bundle ?? Bundle.main).url(forResource: filename, withExtension: "xml")!
        let xml = try! String.init(contentsOf: url)
        return self.read(xml: xml)
    }

    static func read(xml string: String) -> OpenSearchDescription {
        let indexer = SWXMLHash.parse(string)

        return OpenSearchDescription(indexer: indexer)
    }
}
