//
//  ViewController.swift
//  Blotchy
//
//  Created by Joshua May on 5/6/18.
//  Copyright © 2018 Joshua May and Keith Lang. All rights reserved.
//

import Cocoa

let PerformSearchSegue = "PerformSearch"

class ViewController: NSViewController {
    var string: String?

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == PerformSearchSegue {
//            if let wc = segue.destinationController as? SearchWindowController,
//                let string = string {
//                wc.searchTerm = string
//            }
        }
    }

    // MARK: - Actions
    @IBAction func handleViaAccessibilityPressed(sender: Any) {
        let grabber = AccessibilitySelectedTextGrabber()

        grabber.selectedTextInActiveApp() { [weak self] string in
            guard let string = string else {
                return
            }

            self?.string = string

            self?.maybeLaunchBrowser()
        }
    }

    // MARK: - helper
    func maybeLaunchBrowser() {
        if string != nil {
            // TODO: only present one window at a time, doofus
            performSegue(withIdentifier: PerformSearchSegue, sender: self)
        }
    }
}

//extension ViewController: CursorGestureTrackerDelegate {
//    func didFlingRight() {
//        print("showing")
//        view.window?.level = .floating
//    }
//
//    func didFlingLeft() {
//        print("hiding")
//        view.window?.level = .normal
//        NSApp
//    }
//}
