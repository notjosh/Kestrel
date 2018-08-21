//
//  ContextPreferencesViewController.swift
//  Blotchy
//
//  Created by Joshua May on 20/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Cocoa
import MASPreferences

let DragPasteboardType = NSPasteboard.PasteboardType(rawValue: "ContextPreferencesViewControllerType")

class ContextPreferencesViewController: NSViewController {
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var contextArrayController: NSArrayController!
    @IBOutlet var searchEngineArrayController: NSArrayController!

    var contextService = ContextService.shared
    var searchEngineService = SearchEngineService.shared
    let dataStack = DataStack.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerForDraggedTypes([DragPasteboardType])

        contextArrayController.entityName = Context.entityName()
        contextArrayController.managedObjectContext = dataStack.viewContext
        contextArrayController.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Context.order), ascending: true),
        ]

        searchEngineArrayController.entityName = SearchEngine.entityName()
        searchEngineArrayController.managedObjectContext = dataStack.viewContext
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        let moc = dataStack.viewContext

        // XXX: commitEditing not available on MOC in 10.14b6
        if true /* moc.commitEditing() */ {
            do {
                print("saving contexts")
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

            new.order = Int16(((contextArrayController.arrangedObjects as? [AnyObject]) ?? []).count)

            try? moc.save()
        }
    }

    @IBAction func handleRemovePressed(sender: Any) {
        let indexSet = contextArrayController.selectionIndexes
        contextArrayController.remove(atArrangedObjectIndexes: indexSet)

        // fill in gaps in arrangment
        if let arrangedObjects = contextArrayController.arrangedObjects as? [Context] {
            for (index, context) in arrangedObjects.enumerated() {
                context.order = Int16(index)
            }

            try? contextArrayController.managedObjectContext?.save()
            contextArrayController.rearrangeObjects()
        }
    }
}

extension ContextPreferencesViewController: NSTableViewDataSource {
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        pboard.declareTypes([DragPasteboardType], owner: self)
        pboard.setData(data, forType: DragPasteboardType)

        return true
    }

    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        } else {
            return []
        }
    }

    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        let pasteboard = info.draggingPasteboard
        let pasteboardData = pasteboard.data(forType: DragPasteboardType)

        if let pasteboardData = pasteboardData {
            if
                let rowIndexes = NSKeyedUnarchiver.unarchiveObject(with: pasteboardData) as? IndexSet,
                rowIndexes.count == 1,
                let rowIndex = rowIndexes.first {

                let target = row > rowIndex ? row - 1 : row

                print("--- \(rowIndex) to \(target)")

                var count = 0

                if let arrangedObjects = contextArrayController.arrangedObjects as? [Context] {
                    for (index, context) in arrangedObjects.enumerated() {

                        if index == target && rowIndex > target {
                            count += 1
                        }

                        if index != rowIndex {
                            print("- \(index) to \(count)")
                            context.order = Int16(count)

                            count += 1
                        }

                        if index == target && rowIndex <= target {
                            count += 1
                        }
                    }

                    print("\(rowIndex) to \(target)")
                    arrangedObjects[rowIndex].order = Int16(target)

                    try? contextArrayController.managedObjectContext?.save()
                    contextArrayController.rearrangeObjects()
                }
            }
        }

        return true
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
