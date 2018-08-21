//
//  SearchEnginePreferencesViewController.swift
//  Kestrel
//
//  Created by Joshua May on 20/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Cocoa
import MASPreferences

class SearchEnginePreferencesViewController: NSViewController {
    @IBOutlet var searchEnginesPopUpButton: NSPopUpButton!
    @IBOutlet var templateTextField: NSTextField!

    let dataStack = DataStack.shared
    var searchEngines = [SearchEngine]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let fr = NSFetchRequest<SearchEngine>(entityName: SearchEngine.entityName())
        fr.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(SearchEngine.order), ascending: true)
        ]
        searchEngines = (try? dataStack.viewContext.fetch(fr)) ?? []

        searchEnginesPopUpButton.removeAllItems()
        searchEnginesPopUpButton.addItems(withTitles: searchEngines.map { $0.name })

        update(sender: self)
    }

    @IBAction func update(sender: Any) {
        let idx = searchEnginesPopUpButton.indexOfSelectedItem

        guard idx != -1 else {
            return
        }

        // todo: bounds checking?
        let searchEngine = searchEngines[idx]

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
