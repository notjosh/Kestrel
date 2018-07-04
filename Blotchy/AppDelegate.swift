//
//  AppDelegate.swift
//  Blotchy
//
//  Created by Joshua May on 5/6/18.
//  Copyright © 2018 Joshua May and Keith Lang. All rights reserved.
//


import Cocoa
import MASPreferences

enum Identifier: NSStoryboard.SceneIdentifier {
    case searchWindowController = "SearchWindowController"

    case contextPreferencesViewController = "ContextPreferencesViewController"
    case searchEnginePreferencesViewController = "SearchEnginePreferencesViewController"
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var statusItemMenu: NSMenu!
    @IBOutlet lazy var preferencesWindowController: NSWindowController! = {
        let vcs: [NSViewController] = [
            storyboard.instantiateController(withIdentifier: Identifier.searchEnginePreferencesViewController.rawValue) as! NSViewController,
            storyboard.instantiateController(withIdentifier: Identifier.contextPreferencesViewController.rawValue) as! NSViewController,
        ]

        let title = NSLocalizedString("Preferences", comment: "Preferences window title")
        return MASPreferencesWindowController(viewControllers: vcs, title: title)
    }()

    var cursorGestureTracker: CursorGestureTracker = CursorGestureTracker()
    let grabber = ClipboardSelectedTextGrabber()
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    var searchWindowController: SearchWindowController? {
        get {
            return NSApp
                .windows
                .compactMap { $0.windowController }
                .first { $0 is SearchWindowController } as? SearchWindowController
        }
    }

    static var shared: AppDelegate {
        get {
            return NSApp.delegate as! AppDelegate
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        cursorGestureTracker.delegate = self
        cursorGestureTracker.start()

        // menu bar
        // Warm by Pham Duy Phuong Hung from the Noun Project
        // https://thenounproject.com/search/?q=warm&i=1554494
        statusItem.button?.image = NSImage(named: "menu-icon")
        statusItem.menu = statusItemMenu

        #if DEBUG
        // reset app if launched with shift key pressed
        let shiftKeyIsPressed = NSEvent.modifierFlags.contains(.shift)
        if shiftKeyIsPressed {
            let ds = DataStack.shared
            ds.reset()
            SearchEngineService.seed(moc: ds.viewContext)
            ContextService.seed(moc: ds.viewContext)
        }

//        showSearchWindow(with: nil)
//        openPreferences(sender: self)
        #endif
	}

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        var reply: NSApplication.TerminateReply = .terminateNow

        let moc = DataStack.shared.viewContext

        if moc.commitEditing() {
            do {
                try moc.save()
            } catch {
                print(error)

                let result = NSApp.presentError(error)

                if result == true {
                    reply = .terminateCancel
                } else {
                    let alert = NSAlert()
                    alert.messageText = "Quit anyway"
                    alert.informativeText = "Could not save changes while quitting. Quit anyway?"
                    alert.addButton(withTitle: "Yes")
                    alert.addButton(withTitle: "No")
                    let alertValue =  alert.runModal()

                    if alertValue != .alertFirstButtonReturn {
                        reply = .terminateCancel
                    }
                }
            }
        } else {
            reply = .terminateCancel
        }

        return reply
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        cursorGestureTracker.stop()
    }

    var storyboard: NSStoryboard {
        get {
            return NSStoryboard.main!
        }
    }

    // MARK: Actions
    @IBAction func orderFrontStandardAboutPanel(sender: Any) {
        let options: [NSApplication.AboutPanelOptionKey: Any] = [
            // avoid showing standard copyright line, since it's wrong
            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): ""
        ]

        NSApp.orderFrontStandardAboutPanel(options: options)
    }

    @IBAction func openPreferences(sender: Any) {
        preferencesWindowController.showWindow(sender)
    }
}

extension AppDelegate: CursorGestureTrackerDelegate {
    func didFlingLeft() {
        print("made it left")

        searchWindowController?.close()
        NSApp.hide(self)
    }

    func didFlingRight() {
        print("made it right")

        let shiftKeyIsPressed = NSEvent.modifierFlags.contains(.shift)

        // show window, without copying, in "search" mode
        if shiftKeyIsPressed {
            showSearchWindow(with: nil)
            return
        }

        // otherwise, show window by copying what's selected on screen
        grabber.selectedTextInActiveApp() { [weak self] string in
            guard let string = string else {
                print("couldn't find any new text on the clipboard :(")
                return
            }

			self?.showSearchWindow(with: string)
        }
    }

	func showSearchWindow(with searchTerm: String?) {
        // we should only have one of these windows, okay
        if let searchWindowController = searchWindowController {
            if let searchTerm = searchTerm {
                searchWindowController.update(searchTerm)
            }
            return
        }

        let wc = storyboard.instantiateController(withIdentifier: Identifier.searchWindowController.rawValue)

        guard let swc = wc as? SearchWindowController else {
            return
        }

        if let searchTerm = searchTerm {
            swc.update(searchTerm)
        }

        swc.window?.level = .floating
        swc.window?.isReleasedWhenClosed = true
        swc.window?.makeKeyAndOrderFront(self)
    }
	
//	func showFloatingSearchButton() {
//		// todo show the floating search button
//	}
}
