//
//  InputForm.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 26.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

fileprivate let keyboardTypesForAccessoryInput: Set<UIKeyboardType> = Set([.numberPad, .decimalPad, .phonePad])

protocol InputForm: UITextFieldDelegate {
    
    var scrollView: UIScrollView! {get}
    
    var textFields: [UITextField] {get}
    
    var submitButton: UIButton! {get}
    
    func addAccessoryButton(to textField: UITextField, withTitle title: String, width: CGFloat) -> Observable<UITextField>
    
    func setupFormUX(forWidth width: CGFloat, disposedBy disposeBag: DisposeBag)
    
    func goToTextField(after textField: UITextField) -> Bool
    
    func submitForm()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool

}

extension InputForm {
    
    var scrollView: UIScrollView! {
        return nil
    }
    
    var submitButton: UIButton! {
        return nil
    }
    
    func addAccessoryButton(to textField: UITextField, withTitle title: String, width: CGFloat) -> Observable<UITextField> {
        let accessoryButton = createAccessoryButton(withTitle: title, width: width)
        textField.inputAccessoryView = accessoryButton
        return accessoryButton.rx.tap
            .map{[weak textField] in textField}
            .filterNil()
    }
 
    func goToTextField(after textField: UITextField) -> Bool {
        
        if let currentIndex = textFields.index(of: textField), currentIndex < textFields.count - 1 {
            textFields[currentIndex+1].becomeFirstResponder()
            return false
        } else {
            textField.resignFirstResponder()
            submitForm()
        }
        
        return true
    }
    
    func submitForm() {
        if let submitButton = submitButton {
            submitButton.sendActions(for: .touchUpInside)
        }
    }
    
    fileprivate func createAccessoryButton(withTitle title: String, width: CGFloat) -> UIButton {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: width, height: 45.0)
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        button.titleLabel?.textColor = UIColor.white
        
        return button
    }
    
    func setupFormUX(forWidth width: CGFloat, disposedBy disposeBag: DisposeBag) {
        scrollView?.subscribeKeyBoard(withDisposeBag: disposeBag)
        
        guard let lastField = textFields.last else {
            return
        }
        setupTextField(lastField, returnKeyType: .done, accessoryButtonWidth: width)?
            .disposed(by: disposeBag)
        
        textFields.flatMap { textField in
            textField.delegate = self
            
            guard textField != lastField else {
                return nil
            }
            return setupTextField(textField, returnKeyType: .next, accessoryButtonWidth: width)
        }.disposed(by: disposeBag)
    }
    
    private func setupTextField(_ textField: UITextField, returnKeyType: UIReturnKeyType, accessoryButtonWidth width: CGFloat) -> Disposable? {
        textField.returnKeyType = returnKeyType
        textField.delegate = self
        if keyboardTypesForAccessoryInput.contains(textField.keyboardType) || textField.inputView != nil {
            let title: String!
            switch returnKeyType {
            case .next:
                title = Localize("newDesign.next")
            case .done:
                title = Localize("newDesign.done")
            default:
                fatalError("Selected returnKeyType (\(returnKeyType)) is not supported")
            }
            
            return addAccessoryButton(to: textField, withTitle: title, width: width)
                .subscribe(onNext: { [weak self] in
                    _ = self?.goToTextField(after: $0)
                })
        }
        return nil
    }
    
}
    
    
extension InputForm where Self: UIViewController {
    
    func setupFormUX(disposedBy disposeBag: DisposeBag) {
        setupFormUX(forWidth: self.view.bounds.width, disposedBy: disposeBag)
    }
    
}
