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
}

extension ContextPreferencesViewController: MASPreferencesViewController {
    var viewIdentifier: String {
        return NSStringFromClass(type(of: self))
    }

    var toolbarItemLabel: String? {
        return NSLocalizedString("Contexts", comment: "Preferences tab label: Contexts")
    }
}
