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

//    var detailViewController: ContextDetailPreferencesViewController! {
//        guard
//            let vc = children.first(where: { $0 is ContextDetailPreferencesViewController }) as? ContextDetailPreferencesViewController
//            else {
//            fatalError("where did your detail view controller (ContextDetailPreferencesViewController) go?")
//        }
//
//        return vc
//    }

    var contextService = ContextService.shared
    var searchEngineService = SearchEngineService.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        contextArrayController.content = contextService.contexts
        searchEngineArrayController.content = searchEngineService.searchEngines
    }

    // MARK:- Actions
    @IBAction func handleTableViewAction(sender: Any) {
//        let idx = tableView.clickedRow
//
//        guard
//            idx != -1
//            else {
//                detailViewController.context = nil
//                return
//        }
//
//        let context = contextService.contexts[idx]
//        detailViewController.context = context
    }

//    @IBAction func handleTextFieldFinished(sender: Any) {
//        let idx = tableView.selectedRow
//        guard
//            let row = tableView.rowView(atRow: idx, makeIfNecessary: false)
//            else {
//                return
//        }
//
//        guard
//            let titleView = row.view(atColumn: 0) as? NSTableCellView,
//            let title = titleView.objectValue as? String
//            else {
//                return
//        }
//
//        let old = contextService.contexts[idx]
//
//        let new = Context(
//            name: title,
//            searchEngine: old.searchEngine,
//            terms: old.terms
//        )
//
//        contextService.update(new, at: idx)
//
//        tableView.reloadData()
//    }

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
        guard let se = searchEngineService.searchEngines.first else {
            fatalError()
        }

        let new = Context(name: "New Context",
                          searchEngine: se,
                          terms: [],
                          color: NSColor.red)

        contextArrayController.addObject(new)
    }

    @IBAction func handleRemovePressed(sender: Any) {
        let indexSet = contextArrayController.selectionIndexes
        contextArrayController.remove(atArrangedObjectIndexes: indexSet)
    }
}

extension ContextPreferencesViewController: NSTableViewDataSource {
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        return contextService.contexts.count
//    }
//
//    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//        guard let tableColumn = tableColumn else {
//            return ""
//        }
//
//        let context = contextService.contexts[row]
//
//        switch tableView.tableColumns.firstIndex(of: tableColumn) {
//        case 0:
//            return context.name
//        default:
//            return ""
//        }
//    }
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
