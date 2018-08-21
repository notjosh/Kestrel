//
//  OpenSearchTests.swift
//  KestrelTests
//
//  Created by Joshua May on 21/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import XCTest
@testable import Kestrel

class OpenSearchTests: XCTestCase {
    func testSimple() {
        let os = OpenSearch.read(named: "sample.simple", bundle: Bundle(for: type(of: self)))

        XCTAssertEqual(os.shortName, "Web Search")
        XCTAssertEqual(os.description, "Use Example.com to search the Web.")
        XCTAssertEqual(os.tagsText, "example web")
        XCTAssertEqual(os.tags, ["example", "web"])
        XCTAssertEqual(os.contact, "admin@example.com")
        XCTAssertEqual(os.url, "http://example.com/?q={searchTerms}&pw={startPage?}&format=rss")
        XCTAssertEqual(os.urls["application/rss+xml"]!, "http://example.com/?q={searchTerms}&pw={startPage?}&format=rss")
    }

    func testDetailed() {
        let os = OpenSearch.read(named: "sample.detailed", bundle: Bundle(for: type(of: self)))

        XCTAssertEqual(os.shortName, "Web Search")
        XCTAssertEqual(os.longName, "Example.com Web Search")
        XCTAssertEqual(os.description, "Use Example.com to search the Web.")
        XCTAssertEqual(os.tagsText, "example web")
        XCTAssertEqual(os.tags, ["example", "web"])
        XCTAssertEqual(os.contact, "admin@example.com")
        XCTAssertEqual(os.url, "http://example.com/?q={searchTerms}&pw={startPage?}&format=atom")
        XCTAssertEqual(os.urls["application/rss+xml"]!, "http://example.com/?q={searchTerms}&pw={startPage?}&format=rss")
        XCTAssertEqual(os.urls["application/atom+xml"]!, "http://example.com/?q={searchTerms}&pw={startPage?}&format=atom")
        XCTAssertEqual(os.urls["text/html"]!, "http://example.com/?q={searchTerms}&pw={startPage?}")
    }
}
