//
//  TextFieldAlert.swift
//  pock_headline_news
//
//  Created by p-x9 on 2021/09/21.
//  
//

import Cocoa

class TextFieldAlert: NSViewController {

    var titleMessage = String() {
        didSet {
            self.titleLabel?.stringValue = titleMessage
        }
    }

    var mainMessage = String() {
        didSet {
            self.messageLabel?.stringValue = mainMessage
        }
    }

    var placeholder = String() {
        didSet {
            self.textField?.placeholderString = placeholder
        }
    }

    var text: String {
        self.textField.stringValue
    }

    var cancelButtonHandler:(() -> Void)?
    var okButtonHandler:(() -> Void)?
    var textChangedHandler: ((String) -> Void)?

    @IBOutlet private var titleLabel: NSTextField!
    @IBOutlet private var messageLabel: NSTextField!
    @IBOutlet private var textField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.stringValue = titleMessage
        self.messageLabel.stringValue = mainMessage
        self.textField.placeholderString = placeholder
    }

    @IBAction private func handleOKButton(_ sender: Any) {
        self.okButtonHandler?()
    }

    @IBAction private func handleCancelButton(_ sender: Any) {
        self.cancelButtonHandler?()
    }

    @IBAction private func textFieldChanged(_ sender: Any) {
        self.textChangedHandler?(self.text)
    }

}
