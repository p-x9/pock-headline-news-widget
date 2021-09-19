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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidDisappear() {
        let panel = NSFontManager.shared.fontPanel(true)
        panel?.close()
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

    @IBAction private func textColorChanged(_ sender: Any) {
        Defaults[.textColor] = self.textColorWell.color.rgbaInt
        NSWorkspace.shared.notificationCenter.post(name: .shouldChangeTextColor, object: nil)
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
        NSWorkspace.shared.notificationCenter.post(name: .shouldChangeTextSpeed, object: nil)
    }

    func update(font: NSFont) {
        Defaults[.fontSize] = font.pointSize
        Defaults[.fontName] = font.fontName
        NSWorkspace.shared.notificationCenter.post(name: .shouldChangeFont, object: nil)
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
