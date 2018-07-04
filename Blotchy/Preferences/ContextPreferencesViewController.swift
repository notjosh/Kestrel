//
//  ContextPreferencesViewController.swift
//  Blotchy
//
//  Created by Joshua May on 20/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Cocoa
import MASPreferences

class ContextPreferencesViewController: NSViewController {
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var contextArrayController: NSArrayController!
    @IBOutlet var searchEngineArrayController: NSArrayController!

    var contextService = ContextService.shared
    var searchEngineService = SearchEngineService.shared
    let dataStack = DataStack.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        contextArrayController.entityName = Context.entityName()
        contextArrayController.managedObjectContext = dataStack.viewContext

        searchEngineArrayController.entityName = SearchEngine.entityName()
        searchEngineArrayController.managedObjectContext = dataStack.viewContext
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        let moc = dataStack.viewContext

        if moc.commitEditing() {
            do {
                try moc.save()
            } catch {
                print(error)
            }
        }
    }

    // MARK:- Actions
    @IBAction func handleSegmentedControlPressed(sender: Any) {
        enum Actions: Int {
            case add
            case remove
        }

        guard let segmented = sender as? NSSegmentedControl else {
            return
        }

        let segment = segmented.selectedSegment
        let tag = segmented.tag(forSegment: segment)
        guard
            let action = Actions(rawValue: tag)
            else {
                return
        }

        switch action {
        case .add:
            handleAddPressed(sender: sender)
        case .remove:
            handleRemovePressed(sender: sender)
        }
    }

    @IBAction func handleAddPressed(sender: Any) {
        guard let se = searchEngineArrayController.selectedObjects.first as? SearchEngine else {
            fatalError()
        }

        guard let moc = contextArrayController.managedObjectContext else {
            fatalError()
        }

        if let new = contextArrayController.newObject() as? Context {
            new.name = "New Context"
            new.searchEngine = se
            new.terms = []
            new.color = NSColor.red

            try? moc.save()
        }
    }

    @IBAction func handleRemovePressed(sender: Any) {
        let indexSet = contextArrayController.selectionIndexes
        contextArrayController.remove(atArrangedObjectIndexes: indexSet)
    }
}

extension ContextPreferencesViewController: NSTableViewDelegate {
}

extension ContextPreferencesViewController: MASPreferencesViewController {
    var viewIdentifier: String {
        return NSStringFromClass(type(of: self))
    }

    var toolbarItemLabel: String? {
        return NSLocalizedString("Contexts", comment: "Preferences tab label: Contexts")
    }
}
