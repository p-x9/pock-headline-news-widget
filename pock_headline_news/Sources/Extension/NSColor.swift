//
//  NSColor.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/09/17.
//  
//

import Cocoa

extension NSColor {
    static let touchBarBackgroundColor = NSColor(red: 54 / 256, green: 54 / 256, blue: 54 / 256, alpha: 1.0)
    static var random: NSColor {
        let r = CGFloat.random(in: 0 ... 255) / 255.0
        let g = CGFloat.random(in: 0 ... 255) / 255.0
        let b = CGFloat.random(in: 0 ... 255) / 255.0
        return NSColor(red: r, green: g, blue: b, alpha: 1.0)
    }

}

extension NSColor {
    convenience init(rgb: Int) {
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat( rgb & 0x0000FF       ) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }

    convenience init(rgba: Int) {
        let r = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
        let g = CGFloat((rgba & 0x00FF0000) >> 16) / 255.0
        let b = CGFloat((rgba & 0x0000FF00) >> 8) / 255.0
        let a = CGFloat( rgba & 0x000000FF       ) / 255.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }

    convenience init?(rgb code: String) {
        var color: UInt64 = 0
        let code = code.replacingOccurrences(of: "#", with: "")
        if Scanner(string: code).scanHexInt64(&color) {
            self.init(rgb: Int(color))
            return
        }
        return nil
    }

    convenience init?(rgba code: String) {
        var color: UInt64 = 0
        let code = code.replacingOccurrences(of: "#", with: "")
        if Scanner(string: code).scanHexInt64(&color) {
            self.init(rgba: code)
            return
        }
        return nil
    }
}

extension NSColor {
    private enum Component: Int {
        case red, green, blue, alpha
    }

    var redComponent: CGFloat {
        getComponent(.red)
    }

    var blueComponent: CGFloat {
        getComponent(.blue)
    }

    var greenComponent: CGFloat {
        getComponent(.green)
    }

    var alphaComponent: CGFloat {
        getComponent(.alpha)
    }

    private var rgbaArray: [CGFloat] {
        var red: CGFloat = -1
        var blue: CGFloat = -1
        var green: CGFloat = -1
        var alpha: CGFloat = 1
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue, alpha]
    }

    private func getComponent(_ component: Component) -> CGFloat {
        self.rgbaArray[component.rawValue]
    }
}

extension NSColor {
    var rgbString: String {
        let rgb = Array(self.rgbaArray[0...2])
        return rgb.reduce(into: "") {res, value in
            let intval = Int(round(value * 255))
            res += (NSString(format: "%02X", intval) as String)
        }
    }

    var rgbaString: String {
        let rgba = self.rgbaArray
        return rgba.reduce(into: "") {res, value in
            let intval = Int(round(value * 255))
            res += (NSString(format: "%02X", intval) as String)
        }
    }

    var rgbInt: Int {
        let rgba = self.rgbaArray
        let r = Int(rgba[0] * 255) << 16
        let g = Int(rgba[1] * 255) << 8
        let b = Int(rgba[2] * 255)

        return [r, g, b].reduce(0, +)
    }

    var rgbaInt: Int {
        let rgba = self.rgbaArray
        let r = Int(rgba[0] * 255) << 24
        let g = Int(rgba[1] * 255) << 16
        let b = Int(rgba[2] * 255) << 8
        let a = Int(rgba[3] * 255)

        return [r, g, b, a].reduce(0, +)
    }
}
