//
//  TextFieldNextDelegate.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/10/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

protocol TextFieldNextDelegate: UITextFieldDelegate {
    
    var textFields: [UITextField]! {get}
    var submitButton: UIButton! {get}
    
    func goToNextField(withCurrentField textField: UITextField) -> Bool
    
    func performSubmit()
    
}

extension TextFieldNextDelegate {
    func goToNextField(withCurrentField textField: UITextField) -> Bool {
        if let currentIndex = textFields.index(of: textField), currentIndex < textFields.count-1 {
            textFields[currentIndex+1].becomeFirstResponder()
            return false
        } else {
            textField.resignFirstResponder()
            performSubmit()
        }
        
        return true
    }
    
    func performSubmit() {
        submitButton.sendActions(for: UIControlEvents.touchUpInside)
    }
    
}
