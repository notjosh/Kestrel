//
//  SelectedTextGrabber.swift
//  Kestrel
//
//  Created by Joshua May on 6/6/18.
//  Copyright © 2018 Joshua May and Keith Lang. All rights reserved.
//

import Cocoa
import AXSwift

// yay:
import Carbon.HIToolbox

typealias SelectedTextGrabberCallback = (String?) -> ()

protocol SelectedTextGrabber {
    func selectedTextInActiveApp(then callback: @escaping SelectedTextGrabberCallback)
}

class ClipboardSelectedTextGrabber: SelectedTextGrabber {
    func selectedTextInActiveApp(then callback: @escaping SelectedTextGrabberCallback) {
        guard UIElement.isProcessTrusted(withPrompt: true) else {
            print("UIElement.isProcessTrusted fails")
            callback(nil)
            return
        }

        let top = topOfClipboard()

        self.performGlobalCopyShortcut()

        // wait for copy. super arbitrary timeout.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let top = top,
                let newTop = self?.topOfClipboard(),
                top !== newTop,
                let string = newTop.string(forType: .string)
                else {
                    print("nothing found on clipboard")
                    callback(nil)
                    return
            }

            print("clipboard text:", string)
            callback(string)
        }
    }

    // MARK: Helper
    func topOfClipboard() -> NSPasteboardItem? {
        return NSPasteboard.general.pasteboardItems?.first
    }

    func performGlobalCopyShortcut() {
        let eventSource = CGEventSource(stateID: .hidSystemState)

        func keyEvents(forPressAndReleaseVirtualKey virtualKey: Int) -> [CGEvent] {
            return [
                CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: true)!,
                CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: false)!,
            ]
        }

        keyEvents(forPressAndReleaseVirtualKey: kVK_ANSI_C)
            .forEach {
                $0.flags = .maskCommand
                $0.post(tap: .cghidEventTap)
        }
    }
}

class AccessibilitySelectedTextGrabber: SelectedTextGrabber {
    func selectedTextInActiveApp(then callback: @escaping SelectedTextGrabberCallback) {
        guard UIElement.isProcessTrusted(withPrompt: true) else {
            print("UIElement.isProcessTrusted fails")
            callback(nil)
            return
        }

        guard let frontmostApplication = NSWorkspace.shared.frontmostApplication else {
            print("can't find application at front, bailing")
            callback(nil)
            return
        }

        guard let application = Application(frontmostApplication) else {
            print("AX can't find application for frontmost application '\(frontmostApplication)'")
            callback(nil)
            return
        }

        guard let maybeTitle = try? application.attribute(.title) as String?,
            let title = maybeTitle else {
                print("AX can't find window title, probably bad. bailing.")
                callback(nil)
                return
        }

        print("looking in window: \(title)")

        guard let maybeElement = try? application.attribute(.focusedUIElement) as UIElement?,
            let element = maybeElement else {
                print("can't find focused element, bailing")
                callback(nil)
                return
        }

        print("found focused element: \(element)")

        guard let maybeSelectedText = try? element.attribute(.selectedText) as String?,
            let selectedText = maybeSelectedText else {
                print("can't find selected text, bailing")
                callback(nil)
                return
        }

        guard selectedText != "" else {
            print("selected text is an empty string, bailing")
            callback(nil)
            return
        }

        print("found selected text: '\(selectedText)'")

        return callback(selectedText)
    }
}
