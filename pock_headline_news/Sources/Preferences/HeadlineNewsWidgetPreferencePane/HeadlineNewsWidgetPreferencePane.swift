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
            self.speedSlider.minValue = 0.001
            self.speedSlider.maxValue = 2.0
            self.speedSlider.doubleValue = Double(Defaults[.textSpeed])
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
        Defaults[.textSpeed] = CGFloat(self.speedSlider.doubleValue)
    }

    @IBAction private func textColorChanged(_ sender: Any) {
        Defaults[.textColor] = self.textColorWell.color.rgbaInt
        NSWorkspace.shared.notificationCenter.post(name: .shouldChangeTextColor, object: nil)
    }

}
