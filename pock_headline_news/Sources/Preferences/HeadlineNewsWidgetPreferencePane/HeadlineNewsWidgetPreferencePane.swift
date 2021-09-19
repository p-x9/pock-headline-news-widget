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

    override func viewDidLoad() {
        super.viewDidLoad()
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

    func update(speed: Float) {
        Defaults[.textSpeed] = speed
        NSWorkspace.shared.notificationCenter.post(name: .shouldChangeTextSpeed, object: nil)
    }
}
