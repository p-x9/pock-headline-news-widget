//
//  HeadlineNewsWidgetPreferencePane.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/09/18.
//  
//

import AppKit
import PockKit

class HeadlineNewsWidgetPreferencePane: NSViewController, PKWidgetPreference {
    static var nibName: NSNib.Name = "\(HeadlineNewsWidgetPreferencePane.self)"

    var rssURLs: [String] = Preferences[.rssURLs]

    @IBOutlet private var rssTableView: NSTableView!

    @IBOutlet private weak var speedSlider: NSSlider! {
        didSet {
            self.speedSlider.minValue = 0.0
            self.speedSlider.maxValue = 2.0
            self.speedSlider.floatValue = Preferences[.textSpeed]
        }
    }
    @IBOutlet private var speedTextField: NSTextField! {
        didSet {
            self.speedTextField.stringValue = String(format: "%.1f", self.speedSlider.floatValue)
        }
    }
    @IBOutlet private var textColorWell: NSColorWell! {
        didSet {
            self.textColorWell.color = NSColor(rgba: Preferences[.textColor])
        }
    }
    @IBOutlet private var fontTextField: NSTextField! {
        didSet {
            self.fontTextField.stringValue = "\(Preferences[.fontName]) \(Int(Preferences[.fontSize]))"
        }
    }
    @IBOutlet private var fontSelectButton: NSButton!
    @IBOutlet private var backgroundColorWell: NSColorWell! {
        didSet {
            self.backgroundColorWell.color = NSColor(rgba: Preferences[.backgroundColor])
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.rssTableView.delegate = self
        self.rssTableView.dataSource = self
        self.rssTableView.target = self
        self.rssTableView.doubleAction = #selector(handleTableViewDoubleClicked)
    }

    override func viewDidDisappear() {
        let panel = NSFontManager.shared.fontPanel(true)
        panel?.close()
    }

    @IBAction private func speedSliderValueChanged(_ sender: Any) {
        self.speedTextField.stringValue = String(format: "%.1f", self.speedSlider.floatValue)
        self.update(speed: self.speedSlider.floatValue)
    }

    @IBAction private func speedTextFieldChanged(_ sender: Any) {
        let range = self.speedSlider.minValue ... self.speedSlider.maxValue
        if let value = Float(self.speedTextField.stringValue),
           range.contains(Double(value)) {
            self.speedSlider.floatValue = value
            self.update(speed: self.speedSlider.floatValue)
        } else {
            self.speedTextField.stringValue = String(format: "%.1f", self.speedSlider.floatValue)
        }
    }

    @IBAction private func colorChanged(_ sender: Any) {
        guard let colorWell = sender as? NSColorWell else {
            return
        }
        switch colorWell {
        case self.textColorWell:
            Preferences[.textColor] = colorWell.color.rgbaInt
        case self.backgroundColorWell:
            Preferences[.backgroundColor] = colorWell.color.rgbaInt
        default:
            break
        }
        NSWorkspace.shared.notificationCenter.post(name: .shouldReloadUISettings, object: nil)
    }

    @IBAction private func handleFontSelectButton(_ sender: Any) {
        let fontManager = NSFontManager.shared
        fontManager.target = self
        let panel = fontManager.fontPanel(true)
        panel?.orderFront(self)
        panel?.isEnabled = true
    }

    @IBAction private func clickedRSSSegmentedControl(_ sender: Any) {
        guard let segmentedControl = sender as? NSSegmentedControl else {
            return
        }

        switch segmentedControl.selectedSegment {
        case 0:// Add
            self.addRssUrl()
        case 1:// Minus
            let selectedIndex = self.rssTableView.selectedRow
            self.removeRssUrl(index: selectedIndex)
        default:
            break
        }
    }

    func addRssUrl() {
        let textAlert = TextFieldAlert(nibName: "\(TextFieldAlert.self)",
                                       bundle: Bundle(identifier: "com.p-x9.pock-headline-news"))

        textAlert.titleMessage = "Add new RSS URL"
        textAlert.mainMessage = "input new rss URL \n Only 'https://' supported"
        textAlert.cancelButtonHandler = {[weak self] in
            self?.dismiss(textAlert)
        }
        textAlert.okButtonHandler = {[weak self] in
            let url = textAlert.text
            if let self = self,
               self.checkFormat(of: url, withAlert: true) {
                self.dismiss(textAlert)
                self.add(rssUrl: url)
            }
        }
        self.presentAsSheet(textAlert)
    }

    func checkFormat(of url: String, withAlert: Bool = false) -> Bool {
        if let url = URL(string: url),
           url.absoluteString.hasPrefix("https://") {
            return true
        }
        if withAlert {
            self.presentAlert(title: "Invalid URL",
                              message: "Please check rss URL.\n(Only 'https://' supported)",
                              style: .critical,
                              completion: nil)
        }
        return false
    }

    func add(rssUrl: String) {
        self.rssURLs.append(rssUrl)
        self.rssTableView.reloadData()
        self.update(rssURLs: self.rssURLs)
    }

    func removeRssUrl(index: Int) {
        if self.rssURLs.indices.contains(index) {
            self.rssURLs.remove(at: index)
            Preferences[.rssURLs] = self.rssURLs
            self.rssTableView.removeRows(at: [index], withAnimation: .effectFade)
            NSWorkspace.shared.notificationCenter.post(name: .shouldChangeRssUrl, object: nil)
        }
    }

    func update(speed: Float) {
        Preferences[.textSpeed] = speed
        NSWorkspace.shared.notificationCenter.post(name: .shouldReloadUISettings, object: nil)
    }

    func update(font: NSFont) {
        Preferences[.fontSize] = font.pointSize
        Preferences[.fontName] = font.fontName
        NSWorkspace.shared.notificationCenter.post(name: .shouldReloadUISettings, object: nil)
    }

    func update(rssURLs: [String]) {
        Preferences[.rssURLs] = self.rssURLs
        NSWorkspace.shared.notificationCenter.post(name: .shouldChangeRssUrl, object: nil)
    }

    @objc
    func handleTableViewDoubleClicked() {
        self.rssTableView.deselectRow(self.rssTableView.clickedRow)
        guard let textFieldCell = self.rssTableView.view(atColumn: self.rssTableView.clickedColumn,
                                                         row: self.rssTableView.clickedRow,
                                                         makeIfNecessary: false) as? TextFieldTableViewCell else {
            return
        }
        textFieldCell.isEditable = true
    }

    func reset() {
        Preferences.reset()
        NSWorkspace.shared.notificationCenter.post(name: .shouldChangeRssUrl, object: nil)
        NSWorkspace.shared.notificationCenter.post(name: .shouldReloadUISettings, object: nil)
    }
}

extension HeadlineNewsWidgetPreferencePane: NSFontChanging {
    func changeFont(_ sender: NSFontManager?) {
        guard let fontManager = sender else {
            return
        }
        let newFont = fontManager.convert(.systemFont(ofSize: 20)) // dummy font
        self.update(font: newFont)
        self.fontTextField.stringValue = "\(newFont.fontName) \(Int(newFont.pointSize))"
    }
}

extension HeadlineNewsWidgetPreferencePane: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        self.rssURLs.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "\(TextFieldTableViewCell.self)")
        let cell = tableView.makeView(withIdentifier: identifier, owner: self) as! TextFieldTableViewCell
        cell.text = self.rssURLs[row]
        cell.valueChangedHandler = {[weak self] text in
            guard let self = self else {
                return
            }
            if self.checkFormat(of: text, withAlert: true) {
                self.rssURLs[row] = text
            } else {
                cell.text = self.rssURLs[row]
            }

        }
        cell.textDidEndEditingHandler = {_ in
            cell.isEditable = false
        }
        return cell
    }

}
