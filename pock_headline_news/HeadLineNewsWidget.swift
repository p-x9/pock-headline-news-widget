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

class HeadLineNewsWidget:NSObject, PKWidget{
    var identifier: NSTouchBarItem.Identifier = NSTouchBarItem.Identifier(rawValue: "\(HeadLineNewsWidget.self)")
    
    var customizationLabel: String = "HeadLineNews"
    
    var view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 30))
    
    let newsLabel:NSTextField = {
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
    
    let rssParser:RSSParser
    var items:[Item]{
        self.rssParser.items
    }
    var currentIndex = 0
    
    public var isHighlighted = false {
        didSet {
            if isHighlighted {
                self.view.layer?.backgroundColor = NSColor.black.highlight(withLevel: 0.25)?.cgColor
            } else {
                self.view.layer?.backgroundColor = NSColor.black.cgColor
            }
        }
    }
    
    override required init() {
        let feedURL = URL(string: "https://news.yahoo.co.jp/rss/topics/top-picks.xml")!
        self.rssParser = RSSParser.init(url: feedURL)
        
        super.init()
        
        self.setupView()
        self.view.addSubview(self.newsLabel)
    }
    
    func viewDidAppear() {
        self.currentIndex = 0
        self.rssParser.parse()
        self.animation()
    }
    
    
    func setupView(){
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .black
        self.view.layer?.cornerRadius = 5
        
        let tapGesture = NSClickGestureRecognizer()
        tapGesture.target = self
        tapGesture.action = #selector(tap)
        tapGesture.allowedTouchTypes = .direct
        self.view.addGestureRecognizer(tapGesture)
    }
    

    func animation(){
        if self.currentIndex < self.items.count{
            let item = self.items[self.currentIndex]
            let news = "【\(item.title)】 \(item.description)"
            self.newsLabel.stringValue = news
            //self.newsLabel.attributedStringValue
            self.newsLabel.sizeToFit()
            self.currentIndex+=1
            self.setAnimation()
        }
        else{
            self.rssParser.parse()
            self.currentIndex = 0
        }
    }
    
    func setAnimation(){
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
    
    
    @objc
    func tap(_ sender: NSGestureRecognizer?) {
        NSLog("\(self.view.frame)")
        print(self.view.frame)
        self.view.layer?.backgroundColor = .black
        self.animation()
    }
    
}

extension HeadLineNewsWidget:CAAnimationDelegate{
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animation()
    }
}

extension HeadLineNewsWidget: PKScreenEdgeMouseDelegate {
    private func shouldHighlight(for location: NSPoint, in view: NSView) -> Bool {
        view.frame.contains(location)
    }
    
    func screenEdgeController(_ controller: PKScreenEdgeController, mouseEnteredAtLocation location: NSPoint, in view: NSView) {
        self.isHighlighted = shouldHighlight(for: location, in: view)
    }
    
    func screenEdgeController(_ controller: PKScreenEdgeController, mouseMovedAtLocation location: NSPoint, in view: NSView) {
        self.isHighlighted = shouldHighlight(for: location, in: view)
    }
    
    func screenEdgeController(_ controller: PKScreenEdgeController, mouseClickAtLocation location: NSPoint, in view: NSView) {
        self.animation()
    }
    
    func screenEdgeController(_ controller: PKScreenEdgeController, mouseExitedAtLocation location: NSPoint, in view: NSView) {
        self.isHighlighted = false
    }
}
