//
//  SearchWindowController.swift
//  Kestrel
//
//  Created by Joshua May on 5/6/18.
//  Copyright © 2018 Joshua May and Keith Lang. All rights reserved.
//

import Cocoa
import CoreFoundation
import HighlightedWebView

class SearchWindowController: NSWindowController {
    var searchViewController: SearchViewController? {
        get {
            guard let vc = contentViewController as? SearchViewController else {
                return nil
            }

            return vc
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()

		
		
		// putting a hack here to not launch past a certain date.

		let date = Date()
		let formatter = DateFormatter()
		formatter.dateFormat = "MM.yyyy"
		let currentMonthYear = formatter.string(from: date)
		
		if ((currentMonthYear == "07.2018") || (currentMonthYear == "08.2018")) {
			print("Date is good")

			}
		else {
			print("Date is not good")
			NSApplication.shared.terminate(self)
			
		}
		//978307200
		
		
		
		
        // proooobably shouldn't be here, but we're the only window that matters for now eh
        NSApp.activate(ignoringOtherApps: true)

        window?.title = "Search: \(searchViewController?.srrrrrch.searchTerm ?? "")"
        window?.makeKeyAndOrderFront(self)

        searchViewController?.delegate = self
		
        if let screen = window?.screen {
            let fraction: CGFloat = 2
            let fractional = screen.visibleFrame.width / fraction

            let elevenOhSix: CGFloat = 1106 // smallest responsive size

            let screenWidth: CGFloat = screen.visibleFrame.width
            let width: CGFloat = min(fractional, elevenOhSix)

            let frame = NSRect(x: screenWidth - width,
                               y: screen.visibleFrame.minY,
                               width: width,
                               height: screen.visibleFrame.height)

            window?.setFrame(frame, display: true)
			
		// adding functionality for text Search

			if let path = Bundle.main.path(forResource: "UIWebViewSearch", ofType: "js"),
			let jsString = try? String(contentsOfFile: path, encoding: .utf8) {
			print(jsString)
		}
		
		
		
		
		}
    }

    func update(_ searchTerm: String) {
        searchViewController?.update(searchTerm)
    }
}

extension SearchWindowController: SearchViewControllerDelegate {
    func didUpdate(searchTerm: String) {
        window?.title = "Search: \(searchTerm)"
    }
}

protocol SearchViewControllerDelegate {
    func didUpdate(searchTerm: String)
}

enum DrawerHeight: Float, Codable {
    case open = 79
    case closed = 49

    var opposite: DrawerHeight {
        get {
            switch self {
            case .open: return .closed
            case .closed: return .open
            }
        }
    }

    var height: CGFloat {
        get {
            switch self {
            case .open: return 79
            case .closed: return 49
            }
        }
    }

    var title: String {
        get {
            switch self {
            case .open: return "⬇️"
            case .closed: return "⬆️"
            }
        }
    }

    var alpha: CGFloat {
        get {
            switch self {
            case .open: return 1
            case .closed: return 0
            }
        }
    }
}

struct ContextScreenState: Codable {
    var searchEngineKey: String
    var searchTerm: String
    var terms: [String]
//    var context: Context? // can be derived??
    var drawerState: DrawerHeight
}

var ContextScreenStateKey = "SearchWindowState"

extension ContextScreenState {

    func save() {
        do {
            let encoded = try PropertyListEncoder().encode(self)
            let defaults = UserDefaults.standard

            defaults.set(encoded, forKey: ContextScreenStateKey)
        } catch {
            // XXX: alert? ignore?
        }
    }

    static func restore() -> ContextScreenState {
        let defaults = UserDefaults.standard

        guard
            let data = defaults.object(forKey: ContextScreenStateKey) as? Data,
            let state = try? PropertyListDecoder().decode(ContextScreenState.self, from: data)
        else {
            // default
            return ContextScreenState(searchEngineKey: "",
                                      searchTerm: "",
                                      terms: [],
                                      drawerState: .open)
        }

        return state
    }
}

class SearchViewController: NSViewController {
    @IBOutlet var searchEnginesPopUpButton: NSPopUpButton!
    @IBOutlet var contextsStackView: NSStackView!
    @IBOutlet var termsStackView: NSStackView!
    @IBOutlet var webView: DHWebView!
    @IBOutlet var searchTermField: NSTextField!
    @IBOutlet var progressBar: ProgressBar!

    @IBOutlet var drawer: NSView!
    @IBOutlet var drawerButton: NSButton!
    @IBOutlet var currentContextContainer: NSView!
    @IBOutlet var drawerHeightConstraint: NSLayoutConstraint!

    let dataStack = DataStack.shared

    var searchEngines = [SearchEngine]()
//    var contexts = [Context]()
    var contextsFetchedResultsController: NSFetchedResultsController<Context>!

    var srrrrrch = ContextScreenState.restore()

    var delegate: SearchViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Safari/605.1.15"

        let sefr = NSFetchRequest<SearchEngine>(entityName: SearchEngine.entityName())
        sefr.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(SearchEngine.order), ascending: true)
        ]
        searchEngines = (try? dataStack.viewContext.fetch(sefr)) ?? []

        let cfr = NSFetchRequest<Context>(entityName: Context.entityName())
        cfr.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Context.order), ascending: true)
        ]

        contextsFetchedResultsController = NSFetchedResultsController(fetchRequest: cfr,
                                                                      managedObjectContext: dataStack.viewContext,
                                                                      sectionNameKeyPath: nil,
                                                                      cacheName: nil)
        contextsFetchedResultsController.delegate = self

        try? contextsFetchedResultsController.performFetch()

//        contexts = (try? dataStack.viewContext.fetch(cfr)) ?? []

        searchEnginesPopUpButton.removeAllItems()
        searchEnginesPopUpButton.addItems(withTitles: searchEngines.map { $0.name })
        let idx = searchEngines.firstIndex(where: {
            $0.key == srrrrrch.searchEngineKey
        })

        searchEnginesPopUpButton.selectItem(at: idx ?? 0)

        coiiintexts()
        terms()
        searchTermField.stringValue = srrrrrch.searchTerm

        drawerHeightConstraint.constant = CGFloat(srrrrrch.drawerState.rawValue)
        drawerButton.title = srrrrrch.drawerState.title

        go()
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        webView.addObserver(self,
                            forKeyPath: "estimatedProgress",
                            options: .new,
                            context: nil)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()

        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }

    // MARK: Observing
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let progress = webView.estimatedProgress * 100
            let isLoading = progress > 0.1
            progressBar.isHidden = !isLoading
            progressBar.setProgress(progress, animated: isLoading)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    // MARK: Actions
    @IBAction func back(sender: AnyObject) {
        webView.goBack()
    }

    @IBAction func handleSearchEngineChange(sender: Any) {
        let idx = searchEnginesPopUpButton.indexOfSelectedItem
        let searchEngine = searchEngines[idx]
        srrrrrch.searchEngineKey = searchEngine.key

        go()
    }

    @IBAction func handleContextChosen(sender: Any) {
        guard
            let button = sender as? NSButton,
            let contexts = contextsFetchedResultsController.fetchedObjects,
            let context = contexts.first(where: { context in
                return context.name == button.title
            })
            else {
                return
        }

        contextsStackView
            .arrangedSubviews
            .compactMap { $0 as? NSButton }
            .filter { $0 != button }
            .forEach {
                $0.state = .off
                $0.layer?.backgroundColor = nil
        }

        button.state = .on
        button.layer?.backgroundColor = context.color.cgColor

        srrrrrch.terms = context.terms.compactMap { $0 as? String }
        srrrrrch.searchEngineKey = context.searchEngine.key
//        srrrrrch.context = context

        terms()

        searchEnginesPopUpButton.selectItem(withTitle: context.searchEngine.name)

        go()
    }

    @IBAction func handleTermChosen(sender: Any) {
        guard
            let button = sender as? NSButton,
            let idx = srrrrrch.terms.index(of: button.title)
            else {
                return
        }

        srrrrrch.terms.remove(at: idx)
        terms()
        go()
    }

    @IBAction func handleAddTerm(sender: Any) {
        // XXX: should probably be a panel separately, but yolo
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.messageText = "New Term"
        alert.informativeText = "What term would you like to add, friend?"

        let tf = NSTextField(frame: NSRect(x: 0, y: 0, width: 150, height: 20))
        tf.stringValue = ""
        alert.accessoryView = tf

        let response = alert.runModal()

        let text = tf.stringValue

        guard response == .alertFirstButtonReturn,
            text != "",
            srrrrrch.terms.index(of: text) == nil
            else {
                return
        }

        srrrrrch.terms.append(tf.stringValue)
        terms()
        go()
    }

    @IBAction func handleSearchTermChange(sender: Any) {
        update(searchTermField.stringValue)
    }

    @IBAction func handleToggleDrawer(sender: Any) {
        srrrrrch.drawerState = srrrrrch.drawerState.opposite

        drawerHeightConstraint.constant = CGFloat(srrrrrch.drawerState.rawValue)
        drawerButton.title = srrrrrch.drawerState.title

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true

            currentContextContainer.alphaValue = srrrrrch.drawerState.alpha

            view.layoutSubtreeIfNeeded()
        }

        srrrrrch.save()
    }

    // MARK: Helper
    func update(_ searchTerm: String) {
        srrrrrch.searchTerm = searchTerm
        searchTermField.stringValue = srrrrrch.searchTerm

        delegate?.didUpdate(searchTerm: searchTerm)

        go()
    }

    func go() {
        guard
            let searchEngine = selectedSearchEngine(),
            let url = searchEngine.url(for: "\(srrrrrch.searchTerm) \(srrrrrch.terms.joined(separator: " "))")
            else {
                return
        }

        srrrrrch.save()

        let request = URLRequest(url: url)
        webView.mainFrame.load(request)
    }

    func selectedSearchEngine() -> SearchEngine? {
        let idx = searchEnginesPopUpButton.indexOfSelectedItem

        guard
            searchEngines.indices.contains(idx)
            else {
                return nil
        }

        return searchEngines[idx]
    }

    func coiiintexts() {
        contextsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard
            let contexts = contextsFetchedResultsController.fetchedObjects
            else {
                return
        }

        let height: CGFloat = contextsStackView.bounds.height

        contexts.forEach { context in
            let button = NSButton(title: context.name,
                                  target: self,
                                  action: #selector(handleContextChosen(sender:)))
            button.bezelStyle = .recessed
			//button.bezelColor = NSColor.systemBlue
            button.setButtonType(.toggle)
            button.focusRingType = .none

            button.wantsLayer = true

            button.frame = NSRect(x: 0,
                                  y: 0,
                                  width: 0,
                                  height: height)
			
            contextsStackView.addArrangedSubview(button)
        }
    }

    func terms() {
        let height: CGFloat = termsStackView.bounds.height

        termsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        srrrrrch.terms.forEach { term in
            let button = NSButton(title: term,
                                  target: self,
                                  action: #selector(handleTermChosen(sender:)))
            button.bezelStyle = .recessed
            button.setButtonType(.toggle)

            button.wantsLayer = true
            // light blue-ish colour
            button.layer?.backgroundColor = NSColor(red: 210/255,
                                                    green: 231/255,
                                                    blue: 252/255,
                                                    alpha: 1).cgColor

            button.attributedTitle = NSAttributedString(string: button.title,
                                                        attributes: [
                                                            .foregroundColor: NSColor.darkGray,
                                                            ])

            button.frame = NSRect(x: 0,
                                  y: 0,
                                  width: 0,
                                  height: height)

            termsStackView.addArrangedSubview(button)
        }
    }
}

extension SearchViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        switch controller {
        case contextsFetchedResultsController:
            coiiintexts()
        default:
            break
        }
    }
}

extension SearchViewController: WebFrameLoadDelegate {
    func webView(_ sender: WebView!, didStartProvisionalLoadFor frame: WebFrame!) {
//        progressBar.isHidden = false

        // we only care about the root frame for progress updating
        guard sender.mainFrame == frame else {
            return
        }

        // XXX: is this good logic, or
        progressBar.setProgress(0.0, animated: false)
    }

    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
//        progressBar.isHidden = true
    }
}

extension SearchViewController: WebResourceLoadDelegate {
    func webView(_ sender: WebView!, resource identifier: Any!, didFinishLoadingFrom dataSource: WebDataSource!) {
        print("didFinishLoadingFrom")
    }

    func webView(_ sender: WebView!, resource identifier: Any!, didFailLoadingWithError error: Error!, from dataSource: WebDataSource!) {
        print("didFailLoadingWithError")
    }
}

//extension SearchViewController: WKNavigationDelegate {
//    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//    }
//
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//    }
//
//    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//    }
//}
//
//extension SearchViewController: WKUIDelegate {
//}



