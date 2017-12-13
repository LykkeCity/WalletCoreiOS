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

public protocol InputForm: UITextFieldDelegate {
    
    var accessoryButtonBackgroundColor: UIColor {get}
    
    var accessoryButtonTextColor: UIColor {get}
    
    var scrollView: UIScrollView! {get}
    
    var textFields: [UITextField] {get}
    
    var submitButton: UIButton! {get}
    
    func addAccessoryButton(to textField: UITextField, withTitle title: String, width: CGFloat) -> Observable<UITextField>
    
    func setupFormUX(forWidth width: CGFloat, disposedBy disposeBag: DisposeBag)
    
    func goToTextField(after textField: UITextField) -> Bool
    
    func submitForm()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    
}

public extension InputForm {
    
    public var scrollView: UIScrollView! {
        return nil
    }
    
    public var submitButton: UIButton! {
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
        if let submitButton = submitButton, submitButton.isEnabled {
            submitButton.sendActions(for: .touchUpInside)
        }
    }
    
    fileprivate func createAccessoryButton(withTitle title: String, width: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: width, height: 45.0)
        button.setTitle(title, for: .normal)
        button.backgroundColor = accessoryButtonBackgroundColor
        button.tintColor = accessoryButtonTextColor
        
        return button
    }
    
    func setupFormUX(forWidth width: CGFloat, disposedBy disposeBag: DisposeBag) {
        scrollView?.subscribeKeyBoard(withDisposeBag: disposeBag)
        scrollView?.keyboardDismissMode = .onDrag
        
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


public extension InputForm where Self: UIViewController {
    
    func setupFormUX(disposedBy disposeBag: DisposeBag) {
        setupFormUX(forWidth: self.view.bounds.width, disposedBy: disposeBag)
    }
    
    func endEditing() {
        textFields.forEach{ $0.resignFirstResponder() }
        view.endEditing(true)
    }
}

