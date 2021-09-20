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
    static let shouldReloadUISettings = NSNotification.Name("shouldReloadUISettings")
}

extension Defaults.Keys {
    static let rssURLs = Defaults.Key<[String]>("rssURLs", default: ["https://news.yahoo.co.jp/rss/topics/top-picks.xml"])
    static let textSpeed = Defaults.Key<Float>("textSpeed", default: 1)
    static let textColor = Defaults.Key<Int>("textColor", default: 0xFFFFFFFF)
    static let fontName = Defaults.Key<String>("fontName", default: "HelveticaNeue")
    static let fontSize = Defaults.Key<CGFloat>("fontSize", default: 20.0)
    static let backgroundColor = Defaults.Key<Int>("backgroundColor", default: 0x00000000)
}
