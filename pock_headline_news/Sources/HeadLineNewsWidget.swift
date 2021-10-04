//
//  HeadLineNewsWidget.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/09/15.
//  
//

import PockKit
import Cocoa
import SnapKit

class HeadLineNewsWidget: NSObject, PKWidget {
    static var identifier: String = "\(HeadLineNewsWidget.self)"

    var customizationLabel: String = "HeadLineNews"

    var view: NSView!
    let headLineNewsView = HeadLineNewsView(frame: NSRect(x: 0, y: 0, width: 200, height: 30))

    var rssParser: RSSParser
    var items: [Item] = []

    var speed: Float { Preferences[.textSpeed] }
    var textColor: NSColor { NSColor(rgba: Preferences[.textColor]) }
    var font: NSFont {
        NSFont(name: Preferences[.fontName], size: Preferences[.fontSize]) ?? .systemFont(ofSize: 20)
    }
    var backgroundColor: NSColor { NSColor(rgba: Preferences[.backgroundColor]) }
    var isRunning: Bool {
        self.headLineNewsView.isRunning
    }

    var rssURLs: [URL] {
        Preferences[.rssURLs].compactMap { URL(string: $0) }
    }

    override required init() {
        self.rssParser = RSSParser()

        super.init()

        self.view = self.headLineNewsView
        self.headLineNewsView.delegate = self
        self.updateUISettings()

        self.setupTapGesture()
        self.setupLongPressGesture()

        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(updateUISettings),
                                                          name: .shouldReloadUISettings, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(updateRssUrl),
                                                          name: .shouldChangeRssUrl, object: nil)
    }

    func setupTapGesture() {
        let tapGesture = NSClickGestureRecognizer()
        tapGesture.target = self
        tapGesture.action = #selector(tap)
        tapGesture.allowedTouchTypes = .direct
        self.view.addGestureRecognizer(tapGesture)
    }

    func setupLongPressGesture() {
        let longPressGesture = NSPressGestureRecognizer()
        longPressGesture.target = self
        longPressGesture.action = #selector(longPress)
        longPressGesture.allowedTouchTypes = .direct
        self.view.addGestureRecognizer(longPressGesture)
    }

    func openLink() {
        guard let item = self.headLineNewsView.currentItem,
              let url = URL(string: item.link) else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    @objc
    func tap(_ sender: NSGestureRecognizer?) {
        if !self.isRunning {
            self.items = self.rssParser.parse(urls: self.rssURLs)
            self.headLineNewsView.startAnimating(with: items)
        } else {
            self.openLink()
        }
    }

    @objc
    func longPress(_ sender: NSGestureRecognizer?) {
        self.headLineNewsView.stopAnimating()
    }

    @objc
    func updateUISettings() {
        self.headLineNewsView.textColor = self.textColor
        self.headLineNewsView.speed = self.speed
        self.headLineNewsView.font = self.font
        self.headLineNewsView.backgroundColor = self.backgroundColor
    }

    @objc
    func updateRssUrl() {
        self.headLineNewsView.stopAnimating()
        self.items = self.rssParser.parse(urls: self.rssURLs)
        if self.isRunning {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {_ in
                self.headLineNewsView.startAnimating(with: self.items)
            }
        }
    }

}

extension HeadLineNewsWidget: PKScreenEdgeMouseDelegate {
    private func shouldHighlight(for location: NSPoint, in view: NSView) -> Bool {
        headLineNewsView.convert(headLineNewsView.bounds, to: view).contains(location)
    }

    func screenEdgeController(_ controller: PKScreenEdgeController, mouseEnteredAtLocation location: NSPoint, in view: NSView) {
        self.headLineNewsView.isHighlighted = shouldHighlight(for: location, in: view)
    }

    func screenEdgeController(_ controller: PKScreenEdgeController, mouseMovedAtLocation location: NSPoint, in view: NSView) {
        self.headLineNewsView.isHighlighted = shouldHighlight(for: location, in: view)
    }

    func screenEdgeController(_ controller: PKScreenEdgeController, mouseClickAtLocation location: NSPoint, in view: NSView) {
        if !headLineNewsView.isHighlighted {
            return
        }
        if !self.isRunning {
            self.items = self.rssParser.parse(urls: self.rssURLs)
            self.headLineNewsView.startAnimating(with: items)
        } else {
            self.openLink()
        }
    }

    func screenEdgeController(_ controller: PKScreenEdgeController, mouseExitedAtLocation location: NSPoint, in view: NSView) {
        self.headLineNewsView.isHighlighted = false
    }
}

extension HeadLineNewsWidget: HeadLineNewsViewDelegate {
    func nextItems(for view: HeadLineNewsView) -> [Item] {
        self.items = self.rssParser.parse(urls: self.rssURLs)
        return self.items
    }

    func headLineNewsView(_ view: HeadLineNewsView, animationEndedWith items: [Item]) {

    }
}
