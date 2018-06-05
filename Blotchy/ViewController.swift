//
//  ViewController.swift
//  Blotchy
//
//  Created by Joshua May on 5/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Cocoa

let PerformSearchSegue = "PerformSearch"

class ViewController: NSViewController {

    @IBOutlet var statusLabel: NSTextField!
    @IBOutlet var dropTarget: DroppableView!

    var dragging: Bool = false
    var hovering: Bool = false
    var string: String?

    var monitor: Any?

    override func viewDidLoad() {
        super.viewDidLoad()

        dropTarget.registerForDraggedTypes([.string])
        dropTarget.delegate = self

        updateState()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        view.window?.level = .floating

        subscribe()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        unsubscribe()
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == PerformSearchSegue {
            if let wc = segue.destinationController as? SearchWindowController,
                let string = string {
                wc.searchTerm = string
            }
        }
    }

    // MARK: - mouse listening
    func subscribe() {
        guard monitor == nil else {
            return
        }

        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDragged, .leftMouseUp]) { [weak self] event in
            if event.type == .leftMouseUp {
                self?.dragging = false
            } else {
                self?.dragging = true
            }

            self?.updateState()
        }
    }

    func unsubscribe() {
        guard let monitor = monitor else {
            return
        }

        NSEvent.removeMonitor(monitor)
    }

    // MARK: - helper
    func updateState() {
        statusLabel.stringValue = statusForDropTarget()
        dropTarget.layer?.backgroundColor = colorForDropTarget().cgColor

        if dragging {
            view.window?.level = .floating
        } else {
            view.window?.level = .normal
        }
    }

    func statusForDropTarget() -> String {
        switch (dragging, hovering) {
        case (_, true):
            return "hovering: \(string ?? "<unknown>")"
        case (true, false):
            return "dragging"
        default:
            return "idle"
        }
    }

    func colorForDropTarget() -> NSColor {
        switch (dragging, hovering) {
        case (_, true):
            return NSColor.green
        case (true, false):
            return NSColor.orange
        default:
            return NSColor.red
        }
    }
}

extension ViewController: DroppableViewDelegate {
    func draggingEntered(with string: String) {
        self.string = string
        hovering = true
        updateState()
    }

    func draggingEnded(with string: String?) {
        self.string = string
        hovering = false
        updateState()

        if string != nil {
            performSegue(withIdentifier: PerformSearchSegue, sender: self)
        }
    }

    func draggingExited(with string: String?) {
        self.string = string
        hovering = false
        updateState()
    }
}
