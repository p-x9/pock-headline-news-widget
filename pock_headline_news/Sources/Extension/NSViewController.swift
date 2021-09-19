//
//  NSViewController.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/09/19.
//  
//

import Cocoa

extension NSViewController {
    func presentAlert(title: String, message: String, style: NSAlert.Style = .informational, completion: ((Bool) -> Void)?) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style

        alert.addButton(withTitle: "OK")
        alert.buttons[0].keyEquivalent = "\r"        // enter key

        if completion != nil {
            alert.addButton(withTitle: "Cancel")
            alert.buttons[1].keyEquivalent = "\u{1b}"    // esc key
        }

        let ret = alert.runModal()

        completion?(ret == .alertFirstButtonReturn)
    }
}
