//
//  UIViewController Extension.swift
//  News App
//
//  Created by Richard Richard on 14/07/18.
//  Copyright © 2018 Richard. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func isAllTextfieldFilled() -> Bool {
        for case let textField as UITextField in self.view.subviews {
            if let text = textField.text, text.isEmpty {
                return false
            }
        }
        return true
    }
    
    func clearAllTextfield() {
        for case let textField as UITextField in self.view.subviews {
            textField.text = nil
        }
    }
}
