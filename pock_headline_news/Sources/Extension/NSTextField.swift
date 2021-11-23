//
//  NSTextField.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/11/24.
//  
//

import Cocoa

extension NSTextField {
    override open func performKeyEquivalent(with event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let characters = event.charactersIgnoringModifiers?.lowercased()
        switch flags {
        case [.command]:
            let selector: Selector
            switch characters {
            case "x":
                selector = #selector(NSText.cut(_:))
            case "c":
                selector = #selector(NSText.copy(_:))
            case "v":
                selector = #selector(NSText.paste(_:))
            case "a":
                selector = #selector(NSText.selectAll(_:))
            case "z":
                selector = Selector(("undo:"))
            default:
                return super.performKeyEquivalent(with: event)
            }
            return NSApp.sendAction(selector, to: nil, from: self)
        case [.shift, .command] where characters == "z":
            return NSApp.sendAction(Selector(("redo:")), to: nil, from: self)
        default:
            return super.performKeyEquivalent(with: event)
        }
    }
}
