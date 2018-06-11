//
//  AppDelegate.swift
//  Blotchy
//
//  Created by Joshua May on 5/6/18.
//  Copyright © 2018 Joshua May and Keith Lang. All rights reserved.
//

import Cocoa

enum Identifier: NSStoryboard.SceneIdentifier {
    case searchWindowController = "SearchWindowController"
}

@NSApplicationMain


class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var statusItemMenu: NSMenu!
	
	// I apologize for this 🙏
	struct terribleGlobalVariables {
		static var shiftKeyIsPressed: Bool = false
	}
	

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
		
		
		NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) {
			switch $0.modifierFlags.intersection(.deviceIndependentFlagsMask) {
			case [.shift]:
				print("shift key is pressed")
				terribleGlobalVariables.shiftKeyIsPressed = true
			
				
			default:
				print("no modifier keys are pressed")
				terribleGlobalVariables.shiftKeyIsPressed = false
			}
		}
		
		// todo add local event monitor here
		
		
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
}

extension AppDelegate: CursorGestureTrackerDelegate {
    func didFlingLeft() {
        print("made it left")

        searchWindowController?.close()
        NSApp.hide(self)
    }

    func didFlingRight() {
        print("made it right")
        grabber.selectedTextInActiveApp() { [weak self] string in
			let fallbackString = UserDefaults.standard.string(forKey: "recentSearch") ?? ""
			print("the preferences I found was ", fallbackString)
			let searchString = string ?? fallbackString

			
			if terribleGlobalVariables.shiftKeyIsPressed == true || (searchString == string) {
				self?.showSearchWindow(with: searchString, focusOnTextField : false)
			}
        }
    }

	
	
	
	func showSearchWindow(with searchTerm: String, focusOnTextField shouldFocus: Bool) {
        // we should only have one of these windows, okay
        if let searchWindowController = searchWindowController {
            searchWindowController.searchTerm = searchTerm
            return
        }

        let wc = storyboard.instantiateController(withIdentifier: Identifier.searchWindowController.rawValue)

        guard let swc = wc as? SearchWindowController else {
            return
        }

        swc.searchTerm = searchTerm

        swc.window?.level = .floating
        swc.window?.isReleasedWhenClosed = true
        swc.window?.makeKeyAndOrderFront(self)
		if shouldFocus == true {
			print("should focus field")
			//self.searchWindowController?.window?.makeFirstResponder(searchTermField?)
		}
    }
	
//	func showFloatingSearchButton() {
//		// todo show the floating search button
//	}




	
}
