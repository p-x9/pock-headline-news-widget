//
//  TextFieldTableViewCell.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/09/20.
//  
//

import Cocoa
import SnapKit

class TextFieldTableViewCell: NSTableCellView {

    var isEditable = false {
        didSet {
            self.setEditable(self.isEditable)
        }
    }

    var text = ""{
        didSet {
            self.valueTextField.stringValue = self.text
        }
    }

    var valueChangedHandler: ((String) -> Void)?
    var textDidEndEditingHandler: ((String) -> Void)?

    private let valueTextField: NSTextField = {
        let textField = NSTextField()

        textField.textColor = .labelColor
        textField.alignment = .natural
        textField.lineBreakMode = .byClipping
        textField.cell?.isScrollable = true
        textField.cell?.wraps = false
        textField.wantsLayer = true

        return textField
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.setup()
        self.setEditable(false)
        self.valueTextField.target = self
        self.valueTextField.action = #selector(textChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing(_:)),
                                               name: NSTextField.textDidEndEditingNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setup()
        self.setEditable(false)
        self.valueTextField.target = self
        self.valueTextField.action = #selector(textChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing(_:)),
                                               name: NSTextField.textDidEndEditingNotification, object: nil)
    }

    private func setup() {
        self.addSubview(self.valueTextField)
        self.valueTextField.snp.makeConstraints {make in
            make.leading.trailing.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    private func setEditable(_ mode: Bool) {
        self.valueTextField.isEditable = mode
        self.valueTextField.isSelectable = mode
        self.valueTextField.drawsBackground = mode
        self.valueTextField.isBezeled = mode
        self.layer?.backgroundColor = mode ? NSColor.textBackgroundColor.cgColor : .clear

        if mode {
            self.valueTextField.becomeFirstResponder()
        }
        self.needsLayout = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    @objc
    func textChanged() {
        self.valueChangedHandler?(self.valueTextField.stringValue)
    }

    @objc
    func textDidEndEditing(_ notification: Notification) {
        guard let textField = notification.object as? NSTextField else {
            return
        }
        switch textField {
        case self.valueTextField:
        self.textDidEndEditingHandler?(self.valueTextField.stringValue)
        default:
            return
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSTextField.textDidEndEditingNotification, object: nil)
    }

}
