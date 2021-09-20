//
//  RSSParser.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/09/16.
//  
//

import Foundation

class RSSParser {

    init() {}

    func parse(url: URL, completion: @escaping (([Item], Error?) -> Void)) {
        var items: [Item] = []
        let request = NSMutableURLRequest(url: url)
        request.timeoutInterval = 5
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, error in
            if error == nil ,
               let data = data,
               let result = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                print(result)
                items = self.parse(xml: result)
            }
            completion(items, error)
        }
        task.resume()
    }

    func parse(url: URL) -> [Item] {
        var items: [Item] = []
        let request = NSMutableURLRequest(url: url)
        request.timeoutInterval = 5
        request.httpMethod = "GET"

        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, error in
            if error == nil ,
               let data = data,
               let result = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                print(result)
                items = self.parse(xml: result)
            }
            semaphore.signal()
        }
        task.resume()

        semaphore.wait()
        return items
    }

    func parse(urls: [URL]) -> [Item] {
        var items: [Item] = []
        urls.forEach {
            items += self.parse(url: $0)
        }
        return items.sorted { $0.getPubDate() ?? Date()  < $1.getPubDate() ?? Date() }
    }

    private func parse(xml: String) -> [Item] {
        if let doc = try? XMLDocument(xmlString: xml, options: .documentTidyXML),
           let root = doc.rootElement() {
            var items = [XMLNode]()
            do {
                items = try root.nodes(forXPath: "//item")

            } catch {
                print(error)
            }

            return items.compactMap { self.convertToItem(body: $0) }
        }
        return []
    }

    private func convertToItem(body: XMLNode) -> Item? {
        do {
            let title = try body.nodes(forXPath: "title").first?.stringValue ?? ""
            let link = try body.nodes(forXPath: "link").first?.stringValue ?? ""
            let pubDate = try body.nodes(forXPath: "pubDate").first?.stringValue ?? ""
            let description = try body.nodes(forXPath: "description").first?.stringValue ?? ""

            return Item(title: title, pubDate: pubDate, link: link, description: description)
        } catch {
            print(error)
        }
        return nil
    }
}
