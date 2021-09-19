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
    static let shouldChangeRssUrl = NSNotification.Name("shouldChangeRssUrl")
    static let shouldChangeTextColor = NSNotification.Name("shouldChangeColor")
    static let shouldChangeTextSpeed = NSNotification.Name("shouldChangeTextSpeed")
    static let shouldChangeFont = NSNotification.Name("shouldChangeFont")
}

extension Defaults.Keys {
    static let rssUrl = Defaults.Key<String>("rssUrl", default: "https://news.yahoo.co.jp/rss/topics/top-picks.xml")
    static let textSpeed = Defaults.Key<Float>("textSpeed", default: 1)
    static let textColor = Defaults.Key<Int>("textColor", default: 0xFFFFFFFF)
    static let fontName = Defaults.Key<String>("fontName", default: "HelveticaNeue")
    static let fontSize = Defaults.Key<CGFloat>("fontSize", default: 20.0)
}
