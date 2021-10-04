//
//  Preferences.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/09/19.
//  
//

import Foundation
import Defaults

struct Preferences {
    typealias Keys = Defaults.Keys
    typealias Key = Defaults.Key

    static func reset() {
        Keys.rssURLs.reset()
        Keys.textSpeed.reset()
        Keys.textColor.reset()
        Keys.fontName.reset()
        Keys.fontSize.reset()
        Keys.backgroundColor.reset()
    }

    static subscript<Value>(key: Key<Value>) -> Value {
        get {
            Defaults[key]
        }
        set {
            Defaults[key] = newValue
        }
    }

}

extension Preferences.Keys {
    static let rssURLs = Preferences.Key<[String]>("rssURLs", default: ["https://news.yahoo.co.jp/rss/topics/top-picks.xml"])
    static let textSpeed = Preferences.Key<Float>("textSpeed", default: 1)
    static let textColor = Preferences.Key<Int>("textColor", default: 0xFFFFFFFF)
    static let fontName = Preferences.Key<String>("fontName", default: "HelveticaNeue")
    static let fontSize = Preferences.Key<CGFloat>("fontSize", default: 20.0)
    static let backgroundColor = Preferences.Key<Int>("backgroundColor", default: 0x00000000)
}

extension Preferences.Key {
    func reset() {
        Defaults[self] = self.defaultValue
    }
}

extension NSNotification.Name {
    static let shouldChangeRssUrl = NSNotification.Name("shouldChangeRssUrl")
    static let shouldReloadUISettings = NSNotification.Name("shouldReloadUISettings")
}
