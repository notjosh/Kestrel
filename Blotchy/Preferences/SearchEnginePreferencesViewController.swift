//
//  SearchEnginePreferencesViewController.swift
//  Blotchy
//
//  Created by Joshua May on 20/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Cocoa
import MASPreferences

class SearchEnginePreferencesViewController: NSViewController {
    @IBOutlet var searchEnginesPopUpButton: NSPopUpButton!
    @IBOutlet var templateTextField: NSTextField!

    let searchEngineService = SearchEngineService.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        searchEnginesPopUpButton.removeAllItems()
        searchEnginesPopUpButton.addItems(withTitles: searchEngineService.searchEngines.map { $0.name })

        update(sender: self)
    }

    @IBAction func update(sender: Any) {
        let idx = searchEnginesPopUpButton.indexOfSelectedItem

        // todo: bounds checking?
        let searchEngine = searchEngineService.searchEngines[idx]

        templateTextField.stringValue = searchEngine.template
    }
}

extension SearchEnginePreferencesViewController: MASPreferencesViewController {
    var viewIdentifier: String {
        return NSStringFromClass(type(of: self))
    }

    var toolbarItemLabel: String? {
        return NSLocalizedString("Search Engines", comment: "Preferences tab label: Search Engines")
    }
}
