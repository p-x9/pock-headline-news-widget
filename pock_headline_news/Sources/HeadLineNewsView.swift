//
//  HeadLineNewsView.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/09/19.
//  
//

import Cocoa

protocol HeadLineNewsViewDelegate: AnyObject {
    func nextItems(for view: HeadLineNewsView) -> [Item]
    func headLineNewsView(_ view: HeadLineNewsView, animationEndedWith items: [Item])
}

class HeadLineNewsView: NSView {

    private let newsLabel: NSTextField = {
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

        return label
    }()

    var isHighlighted = false {
        didSet {
            if isHighlighted {
                self.layer?.backgroundColor = NSColor.black.highlight(withLevel: 0.25)?.cgColor
            } else {
                self.layer?.backgroundColor = NSColor.black.cgColor
            }
        }
    }

    weak var delegate: HeadLineNewsViewDelegate?
    private(set) var isRunning = false
    private var items = [Item]()

    private var currentIndex = -1
    var currentItem: Item? {
        if self.items.indices.contains(self.currentIndex) {
            return self.items[self.currentIndex]
        }
        return nil
    }

    var speed: Float = 1 {
        didSet {
            guard let layer = self.newsLabel.layer else {
                return
            }

            layer.timeOffset = layer.convertTime(CACurrentMediaTime(), from: nil)
            layer.beginTime = CACurrentMediaTime()
            layer.speed = self.speed
        }
    }

    var textColor: NSColor = .white {
        didSet {
            self.newsLabel.textColor = self.textColor
        }
    }

    var font: NSFont = .systemFont(ofSize: 20) {
        didSet {
            self.newsLabel.font = self.font
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.setupView()
        self.addSubview(self.newsLabel)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupView()
        self.addSubview(self.newsLabel)
    }

    override func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)

        self.isHighlighted = true
    }
    override func touchesEnded(with event: NSEvent) {
        super.touchesEnded(with: event)

        self.isHighlighted = false
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    func setupView() {
        self.wantsLayer = true
        self.layer?.backgroundColor = .black
        self.layer?.cornerRadius = 5
    }

    func animation() {
        self.isRunning = true

        self.currentIndex += 1

        if self.currentIndex < self.items.count {
            let item = self.items[self.currentIndex]
            let news = "【\(item.title)】 \(item.description)"
            self.newsLabel.stringValue = news
            self.newsLabel.sizeToFit()
            self.setAnimation()
        } else {
            self.delegate?.headLineNewsView(self, animationEndedWith: self.items)
            if let items = self.delegate?.nextItems(for: self) {
                self.items = items
            }
            self.currentIndex = -1
            self.animation()
        }
    }

    func setAnimation() {
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        animation.repeatCount = 0
        animation.duration = CFTimeInterval(self.newsLabel.frame.width / 200)
        animation.fromValue = NSValue(point: NSPoint(x: self.frame.width, y: 0))
        animation.toValue = NSValue(point: NSPoint(x: -self.newsLabel.frame.width, y: 0))
        animation.isAdditive = true
        animation.isRemovedOnCompletion = false
        animation.fillMode = .both
        animation.delegate = self
        self.newsLabel.layer?.speed = self.speed
        self.newsLabel.layer?.add(animation, forKey: "position")
    }

    func startAnimating(with items: [Item]) {
        self.items = items
        DispatchQueue.main.async {
            self.animation()
        }
    }

    func stopAnimating() {
        self.currentIndex = -1
        self.isRunning = false
        self.newsLabel.stringValue = ""
        self.newsLabel.layer?.removeAllAnimations()
    }

}

extension HeadLineNewsView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if self.isRunning {
            self.animation()
        }
    }
}
