//
//  RSSParser.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/09/16.
//  
//

import Foundation

class RSSParser {

    var url: URL
    var items: [Item]

    init(url: URL) {
        self.url = url
        self.items = []
    }

    func parse() {
        self.items = []
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, error in
            if error == nil ,
               let data = data,
               let result = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                print(result)
                self.parse(xml: result)
            }
        }
        task.resume()
    }

    private func parse(xml: String) {
        if let doc = try? XMLDocument(xmlString: xml, options: .documentTidyXML),
           let root = doc.rootElement() {
            var items = [XMLNode]()
            do {
                items = try root.nodes(forXPath: "//item")

            } catch {
                print(error)
            }

            items.forEach {body in
                self.addItem(body: body)
            }
        }
    }

    private func addItem(body: XMLNode) {
        do {
            let title = try body.nodes(forXPath: "title").first?.stringValue ?? ""
            let link = try body.nodes(forXPath: "link").first?.stringValue ?? ""
            let pubDate = try body.nodes(forXPath: "pubDate").first?.stringValue ?? ""
            let description = try body.nodes(forXPath: "description").first?.stringValue ?? ""

            self.items.append(Item(title: title, pubDate: pubDate, link: link, description: description))
        } catch {
            print(error)
        }

    }
}
