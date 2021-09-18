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
}

extension Defaults.Keys {
    static let textSpeed = Defaults.Key<CGFloat>("textSpeed", default: 0.5)
    static let textColor = Defaults.Key<Int>("textColor", default: 0xFFFFFFFF)
}
