//
//  LimitedHoshiTextField.swift
//  ModernMoney
//
//  Created by Vladimir Dimov on 3.07.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import TextFieldEffects
import UIKit

@IBDesignable
class LimitedHoshiTextField: HoshiTextField {
    
    @IBInspectable
    var maxLength: Int = 40    // set a default value
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    func editingChanged(sender: UITextField) {
        guard let text = sender.text?.prefix(maxLength) else { return }
        sender.text = String(text)
    }
}
