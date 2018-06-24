//
//  SearchWindowController.swift
//  Blotchy
//
//  Created by Joshua May on 5/6/18.
//  Copyright © 2018 Joshua May and Keith Lang. All rights reserved.
//

import Cocoa
import CoreFoundation
import HighlightedWebView

class SearchWindowController: NSWindowController, SearchViewControllerDataSource {
    var searchViewController: SearchViewController? {
        get {
            guard let vc = contentViewController as? SearchViewController else {
                return nil
            }

            return vc
        }
    }

    var searchTerm: String = "" {
        didSet {
            window?.title = "Search: \(searchTerm)"
            searchViewController?.reload()
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        searchViewController?.dataSource = self

        // proooobably shouldn't be here, but we're the only window that matters for now eh
        NSApp.activate(ignoringOtherApps: true)

        window?.title = "Search: \(searchTerm)"
        window?.makeKeyAndOrderFront(self)

        if let screen = window?.screen {
            let fraction: CGFloat = 2
            let fractional = screen.visibleFrame.width / fraction

            let tenNinetySix: CGFloat = 1096 // smallest responsive size

            let screenWidth: CGFloat = screen.visibleFrame.width
            let width: CGFloat = min(fractional, tenNinetySix)

            let frame = NSRect(x: screenWidth - width,
                               y: screen.visibleFrame.minY,
                               width: width,
                               height: screen.visibleFrame.height)

            window?.setFrame(frame, display: true)
        }
    }
}

protocol SearchViewControllerDataSource {
    var searchTerm: String { get }
}

class SearchViewController: NSViewController {
    @IBOutlet var searchEnginesPopUpButton: NSPopUpButton!
    @IBOutlet var contextsContainer: NSView!
    @IBOutlet var webView: DHWebView!
    @IBOutlet var contextField: NSTextField!
    @IBOutlet var searchTermField: NSTextField!
    @IBOutlet var progressIndicator: NSProgressIndicator!

    let searchEngineService = SearchEngineService.shared
    let contextService = ContextService.shared

    var dataSource: SearchViewControllerDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Safari/605.1.15"

        searchEnginesPopUpButton.removeAllItems()
        searchEnginesPopUpButton.addItems(withTitles: searchEngineService.searchEngines.map { $0.name })

        for (index, context) in contextService.contexts.enumerated() {
            let button = NSButton(title: context.name,
                                  target: self,
                                  action: #selector(handleContextChosen(sender:)))
            let width = 100
            button.frame = NSRect(x: (width + 5) * index,
                                  y: 0,
                                  width: width,
                                  height: 20)
            contextsContainer.addSubview(button)
        }

        if let context = UserDefaults.standard.string(forKey: "context"),
            context != "" {
            contextField.stringValue = context
        }

        if let stringToUseInSearchField = UserDefaults.standard.string(forKey: "recentSearch") {
            searchTermField.stringValue = stringToUseInSearchField
            print("String to use is coming from userdefaults!")
        } else {
            searchTermField.stringValue = ""
        }

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
            progressIndicator.doubleValue = progressIndicator.maxValue * webView.estimatedProgress
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    // MARK: Actions
    @IBAction func handleSearchEngineChange(sender: Any) {
        go()
    }

    @IBAction func handleContextChosen(sender: Any) {
        guard
            let button = sender as? NSButton,
            let context = contextService.contexts.first(where: { context in
                return context.name == button.title
            })
            else {
            return
        }

        contextField.stringValue = context.terms.joined(separator: " ")
        searchEnginesPopUpButton.selectItem(withTitle: context.searchEngine.name)

        go()
    }

    @IBAction func handleContextTerm(sender: Any) {
        UserDefaults.standard.set(contextField.stringValue, forKey: "context")
        go()
    }

    @IBAction func handleSearchTermChange(sender: Any) {
        UserDefaults.standard.set(self.searchTermField.stringValue, forKey: "recentSearch")
        print("searchTermField: ", searchTermField.stringValue)
        go()
    }

    func reload() {
        if let term = dataSource?.searchTerm {
            searchTermField.stringValue = term
        }

        go()
    }

    // MARK: Helper
    func go() {
        guard
            let searchEngine = selectedSearchEngine(),
            let url = searchEngine.url(for: "\(searchTermField.stringValue) \(contextField.stringValue)")
            else {
                return
        }

        UserDefaults.standard.set(searchTermField.stringValue, forKey: "recentSearch")

        let request = URLRequest(url: url)
        webView.mainFrame.load(request)
    }

    func selectedSearchEngine() -> SearchEngine? {
        let idx = searchEnginesPopUpButton.indexOfSelectedItem

        guard
            searchEngineService.searchEngines.indices.contains(idx)
            else {
                return nil
        }

        return searchEngineService.searchEngines[idx]
    }
}

extension SearchViewController: WebFrameLoadDelegate {
    func webView(_ sender: WebView!, didStartProvisionalLoadFor frame: WebFrame!) {
        progressIndicator.isHidden = false
    }

    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        progressIndicator.isHidden = true
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



