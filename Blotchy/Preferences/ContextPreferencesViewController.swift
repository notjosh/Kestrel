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
    let contextService = ContextService.shared
}

extension ContextPreferencesViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return contextService.contexts.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let tableColumn = tableColumn else {
            return ""
        }

        let context = contextService.contexts[row]

        switch tableView.tableColumns.firstIndex(of: tableColumn) {
        case 0:
            return context.name
        case 1:
            return context.searchEngine.name
        case 2:
            return context.terms.joined(separator: ", ")
        default:
            return ""
        }
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
