//
//  Preferences.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/09/19.
//  
//

import Foundation
import Defaults

extension NSNotification.Name {
    static let shouldChangeTextColor = NSNotification.Name("shouldChangeColor")
    static let shouldChangeTextSpeed = NSNotification.Name("shouldChangeTextSpeed")
}

extension Defaults.Keys {
    static let textSpeed = Defaults.Key<Float>("textSpeed", default: 1)
    static let textColor = Defaults.Key<Int>("textColor", default: 0xFFFFFFFF)
}
