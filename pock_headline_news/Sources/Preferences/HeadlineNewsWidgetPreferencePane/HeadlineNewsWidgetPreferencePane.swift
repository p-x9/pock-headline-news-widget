//
//  HeadlineNewsWidgetPreferencePane.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/09/18.
//  
//

import PockKit
import Defaults

class HeadlineNewsWidgetPreferencePane: NSViewController, PKWidgetPreference {
    static var nibName: NSNib.Name = "\(HeadlineNewsWidgetPreferencePane.self)"

    @IBOutlet private var rssTextField: NSTextField! {
        didSet {
            self.rssTextField.stringValue = Defaults[.rssUrl]
        }
    }

    @IBOutlet private weak var speedSlider: NSSlider! {
        didSet {
            self.speedSlider.minValue = 0.0
            self.speedSlider.maxValue = 2.0
            self.speedSlider.floatValue = Defaults[.textSpeed]
        }
    }
    @IBOutlet private var speedTextField: NSTextField! {
        didSet {
            self.speedTextField.stringValue = String(format: "%.1f", self.speedSlider.floatValue)
        }
    }
    @IBOutlet private var textColorWell: NSColorWell! {
        didSet {
            self.textColorWell.color = NSColor(rgba: Defaults[.textColor])
        }
    }
    @IBOutlet private var fontTextField: NSTextField! {
        didSet {
            self.fontTextField.stringValue = "\(Defaults[.fontName]) \(Int(Defaults[.fontSize]))"
        }
    }
    @IBOutlet private var fontSelectButton: NSButton!
    @IBOutlet private var backgroundColorWell: NSColorWell! {
        didSet {
            self.backgroundColorWell.color = NSColor(rgba: Defaults[.backgroundColor])
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidDisappear() {
        let panel = NSFontManager.shared.fontPanel(true)
        panel?.close()
    }

    @IBAction private func rssTextFieldChanged(_ sender: Any) {
        if let url = URL(string: self.rssTextField.stringValue),
           url.absoluteString.hasPrefix("https://") {
            self.update(rssUrl: url)
        } else {
            self.presentAlert(title: "Invalid URL",
                              message: "Please check rss URL.\n(Only 'https://' supported)",
                              style: .critical,
                              completion: nil)
            self.rssTextField.stringValue = Defaults[.rssUrl]
        }
    }

    @IBAction private func speedSliderValueChanged(_ sender: Any) {
        self.speedTextField.stringValue = String(format: "%.1f", self.speedSlider.floatValue)
        self.update(speed: self.speedSlider.floatValue)
    }

    @IBAction private func speedTextFieldChanged(_ sender: Any) {
        let range = self.speedSlider.minValue ... self.speedSlider.maxValue
        if let value = Float(self.speedTextField.stringValue),
           range.contains(Double(value)) {
            self.speedSlider.floatValue = value
            self.update(speed: self.speedSlider.floatValue)
        } else {
            self.speedTextField.stringValue = String(format: "%.1f", self.speedSlider.floatValue)
        }
    }

    @IBAction private func colorChanged(_ sender: Any) {
        guard let colorWell = sender as? NSColorWell else {
            return
        }
        switch colorWell {
        case self.textColorWell:
            Defaults[.textColor] = colorWell.color.rgbaInt
        case self.backgroundColorWell:
            Defaults[.backgroundColor] = colorWell.color.rgbaInt
        default:
            break
        }
        NSWorkspace.shared.notificationCenter.post(name: .shouldReloadUISettings, object: nil)
    }

    @IBAction private func handleFontSelectButton(_ sender: Any) {
        let fontManager = NSFontManager.shared
        fontManager.target = self
        let panel = fontManager.fontPanel(true)
        panel?.orderFront(self)
        panel?.isEnabled = true
    }

    func update(speed: Float) {
        Defaults[.textSpeed] = speed
        NSWorkspace.shared.notificationCenter.post(name: .shouldReloadUISettings, object: nil)
    }

    func update(font: NSFont) {
        Defaults[.fontSize] = font.pointSize
        Defaults[.fontName] = font.fontName
        NSWorkspace.shared.notificationCenter.post(name: .shouldReloadUISettings, object: nil)
    }

    func update(rssUrl: URL) {
        Defaults[.rssUrl] = rssUrl.absoluteString
        NSWorkspace.shared.notificationCenter.post(name: .shouldReloadUISettings, object: nil)
    }
}

extension HeadlineNewsWidgetPreferencePane: NSFontChanging {
    func changeFont(_ sender: NSFontManager?) {
        guard let fontManager = sender else {
            return
        }
        let newFont = fontManager.convert(.systemFont(ofSize: 20)) // dummy font
        self.update(font: newFont)
        self.fontTextField.stringValue = "\(newFont.fontName) \(Int(newFont.pointSize))"
    }
}
