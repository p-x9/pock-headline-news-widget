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
import Defaults

class HeadLineNewsWidget: NSObject, PKWidget {
    var identifier: NSTouchBarItem.Identifier = NSTouchBarItem.Identifier(rawValue: "\(HeadLineNewsWidget.self)")

    var customizationLabel: String = "HeadLineNews"

    var view: NSView!
    let headLineNewsView = HeadLineNewsView(frame: NSRect(x: 0, y: 0, width: 200, height: 30))

    var rssParser: RSSParser
    var items: [Item] {
        self.rssParser.items
    }

    var speed: Float { Defaults[.textSpeed] }
    var textColor: NSColor { NSColor(rgba: Defaults[.textColor]) }
    var isRunning: Bool {
        self.headLineNewsView.isRunning
    }

    override required init() {
        guard let feedURL = URL(string: Defaults[.rssUrl]) else {
            fatalError("should fix url path")
        }
        self.rssParser = RSSParser(url: feedURL)

        super.init()

        self.view = self.headLineNewsView
        self.headLineNewsView.delegate = self
        self.headLineNewsView.speed = self.speed
        self.headLineNewsView.textColor = self.textColor

        let font = NSFont(name: Defaults[.fontName], size: Defaults[.fontSize])
        self.headLineNewsView.font = font ?? .systemFont(ofSize: 20)

        self.setupTapGesture()
        self.setupLongPressGesture()

        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(updateTextColor),
                                                          name: .shouldChangeTextColor, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(updateTextSpeed),
                                                          name: .shouldChangeTextSpeed, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(updateTextFont),
                                                          name: .shouldChangeFont, object: nil)
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
            self.rssParser.parse {[weak self] items, _ in
                self?.headLineNewsView.startAnimating(with: items)
            }
        } else {
            self.openLink()
        }
    }

    @objc
    func longPress(_ sender: NSGestureRecognizer?) {
        self.rssParser.reset()
        self.headLineNewsView.stopAnimating()
    }

    @objc
    func updateTextColor() {
        self.headLineNewsView.textColor = self.textColor
    }

    @objc
    func updateTextSpeed() {
        self.headLineNewsView.speed = self.speed
    }

    @objc
    func updateTextFont() {
        guard let newFont = NSFont(name: Defaults[.fontName], size: Defaults[.fontSize]) else {
            return
        }
        self.headLineNewsView.font = newFont
    }

    @objc
    func updateRssUrl() {
        self.headLineNewsView.stopAnimating()
        guard let rssUrl = URL(string: Defaults[.rssUrl]) else {
            return
        }
        self.rssParser = RSSParser(url: rssUrl)
        self.rssParser.parse {[weak self] items, _ in
            self?.headLineNewsView.startAnimating(with: items)
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
            self.rssParser.parse {[weak self] items, _ in
                self?.headLineNewsView.startAnimating(with: items)
            }
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
        self.rssParser.parse()
        return self.rssParser.items
    }

    func headLineNewsView(_ view: HeadLineNewsView, animationEndedWith items: [Item]) {

    }
}
