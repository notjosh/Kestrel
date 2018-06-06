//
//  SelectedTextGrabber.swift
//  Blotchy
//
//  Created by Joshua May on 6/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Cocoa
import AXSwift

protocol SelectedTextGrabber {
    func selectedTextInActiveApp() -> String?
}

class AccessibilitySelectedTextGrabber: SelectedTextGrabber {
    func selectedTextInActiveApp() -> String? {
        guard UIElement.isProcessTrusted(withPrompt: true) else {
            print("UIElement.isProcessTrusted fails")
            return nil
        }

        guard let frontmostApplication = NSWorkspace.shared.frontmostApplication else {
            print("can't fint application at front, bailing")
            return nil
        }

        guard let application = Application(frontmostApplication) else {
            print("AX can't find application for frontmost application '\(frontmostApplication)'")
            return nil
        }

        guard let maybeTitle = try? application.attribute(.title) as String?,
            let title = maybeTitle else {
                print("AX can't find window title, probably bad. bailing.")
                return nil
        }

        print("looking in window: \(title)")

        guard let maybeElement = try? application.attribute(.focusedUIElement) as UIElement?,
            let element = maybeElement else {
                print("can't find focused element, bailing")
                return nil
        }

        print("found focused element: \(element)")

        guard let maybeSelectedText = try? element.attribute(.selectedText) as String?,
            let selectedText = maybeSelectedText else {
                print("can't find selected text, bailing")
                return nil
        }

        guard selectedText != "" else {
            print("selected text is an empty string, bailing")
            return nil
        }

        print("found selected text: '\(selectedText)'")

        return selectedText
    }
}
