//
//  TextFieldButton.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 10/9/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import WalletCore
import RxSwift

protocol TextFieldButton {
    var view: UIView!{get}
    
    func addDoneButton(_ textField: UITextField, selector: Selector)
    func addButton(forField textField: UITextField, withTitle title: String) -> Observable<UITextField>
}

extension TextFieldButton {
    func addDoneButton(_ textField: UITextField, selector: Selector)
    {
        let doneButton = UIButton()
        doneButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 45.0)
        doneButton.setTitle(Localize("buy.newDesign.done"), for: .normal)
        doneButton.backgroundColor = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        doneButton.titleLabel?.textColor = UIColor.white
        doneButton.addTarget(self, action: selector, for: .touchUpInside)
        
        textField.inputAccessoryView = doneButton
    }
    
    func addButton(forField textField: UITextField, withTitle title: String) -> Observable<UITextField>
    {
        let doneButton = UIButton()
        doneButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 45.0)
        doneButton.setTitle(title, for: .normal)
        doneButton.backgroundColor = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        doneButton.titleLabel?.textColor = UIColor.white
        
        textField.inputAccessoryView = doneButton
        
        return doneButton.rx.tap
            .map{[weak textField] in textField}
            .filterNil()
    }
}
