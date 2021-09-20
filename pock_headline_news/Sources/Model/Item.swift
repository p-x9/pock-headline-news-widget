//
//  Item.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/09/16.
//  
//

import Foundation

struct Item {
    var title: String
    var pubDate: String
    var link: String
    var description: String

    func getPubDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZZ"

        return dateFormatter.date(from: self.pubDate)
    }
}
