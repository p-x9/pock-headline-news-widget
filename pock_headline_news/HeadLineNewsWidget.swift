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
    var identifier: NSTouchBarItem.Identifier = NSTouchBarItem.Identifier(rawValue: "\(HeadLineNewsWidget.self)")

    var customizationLabel: String = "HeadLineNews"

    var view = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 30))

    let newsLabel: NSTextField = {
        let label = NSTextField()
        label.isEditable = false
        label.isSelectable = false
        label.textColor = .labelColor
        label.drawsBackground = false
        label.isBezeled = false
        label.alignment = .natural
        label.font = .systemFont(ofSize: 20)
        label.lineBreakMode = .byClipping
        label.cell?.isScrollable = true
        label.cell?.wraps = false
        label.wantsLayer = true
        label.textColor = #colorLiteral(red: 1, green: 0.5328089595, blue: 0.4345889091, alpha: 1)

        return label
    }()

    let rssParser: RSSParser
    var items: [Item] {
        self.rssParser.items
    }
    var currentIndex = -1
    var currentItem: Item? {
        if self.items.indices.contains(self.currentIndex) {
            return self.items[self.currentIndex]
        }
        return nil
    }

    var isRunning = false

    var isHighlighted = false {
        didSet {
            if isHighlighted {
                self.view.layer?.backgroundColor = NSColor.black.highlight(withLevel: 0.25)?.cgColor
            } else {
                self.view.layer?.backgroundColor = NSColor.black.cgColor
            }
        }
    }

    override required init() {
        guard let feedURL = URL(string: "https://news.yahoo.co.jp/rss/topics/top-picks.xml") else {
            fatalError("should fix url path")
        }
        self.rssParser = RSSParser(url: feedURL)

        super.init()

        self.setupView()
        self.view.addSubview(self.newsLabel)
    }

    func setupView() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .black
        self.view.layer?.cornerRadius = 5

        self.setupTapGesture()
        self.setupLongPressGesture()
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

    func animation() {
        self.isRunning = true

        self.currentIndex += 1

        if self.currentIndex < self.items.count {
            let item = self.items[self.currentIndex]
            let news = "【\(item.title)】 \(item.description)"
            self.newsLabel.stringValue = news
            // self.newsLabel.attributedStringValue
            self.newsLabel.sizeToFit()
            self.setAnimation()
        } else {
            self.rssParser.parse()
            self.currentIndex = -1
        }
    }

    func setAnimation() {
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        animation.repeatCount = 0
        animation.duration = CFTimeInterval(self.newsLabel.frame.width / 100)
        animation.fromValue = NSValue(point: NSPoint(x: self.view.frame.width, y: 0))
        animation.toValue = NSValue(point: NSPoint(x: -self.newsLabel.frame.width, y: 0))
        animation.isAdditive = true
        animation.isRemovedOnCompletion = false
        animation.fillMode = .both
        animation.delegate = self
        self.newsLabel.layer?.add(animation, forKey: "position")
    }

    func openLink() {
        guard let item = self.currentItem,
              let url = URL(string: item.link) else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    @objc
    func tap(_ sender: NSGestureRecognizer?) {
        if !self.isRunning {
            self.rssParser.parse {[weak self] _, _ in
                DispatchQueue.main.async {
                    self?.animation()
                }
            }
        } else {
            self.openLink()
        }
    }

    @objc
    func longPress(_ sender: NSGestureRecognizer?) {
        self.rssParser.reset()
        self.currentIndex = -1
        self.isRunning = false
        self.newsLabel.stringValue = ""
        self.newsLabel.layer?.removeAllAnimations()
    }

}

extension HeadLineNewsWidget: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if self.isRunning {
            animation()
        }
    }
}

extension HeadLineNewsWidget: PKScreenEdgeMouseDelegate {
    private func shouldHighlight(for location: NSPoint, in view: NSView) -> Bool {
        self.view.convert(self.view.bounds, to: view).contains(location)
    }

    func screenEdgeController(_ controller: PKScreenEdgeController, mouseEnteredAtLocation location: NSPoint, in view: NSView) {
        self.isHighlighted = shouldHighlight(for: location, in: view)
    }

    func screenEdgeController(_ controller: PKScreenEdgeController, mouseMovedAtLocation location: NSPoint, in view: NSView) {
        self.isHighlighted = shouldHighlight(for: location, in: view)
    }

    func screenEdgeController(_ controller: PKScreenEdgeController, mouseClickAtLocation location: NSPoint, in view: NSView) {
        if !self.isRunning {
            self.rssParser.parse {[weak self] _, _ in
                DispatchQueue.main.async {
                    self?.animation()
                }
            }
        } else {
            self.openLink()
        }
    }

    func screenEdgeController(_ controller: PKScreenEdgeController, mouseExitedAtLocation location: NSPoint, in view: NSView) {
        self.isHighlighted = false
    }
}
