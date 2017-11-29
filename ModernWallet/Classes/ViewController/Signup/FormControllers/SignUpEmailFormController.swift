//
//  SignUpEmailFormController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 29.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SignUpEmailFormController: FormController {
    
    let email: String
    
    init(email: String) {
        self.email = email
    }
    
    lazy var formViews: [UIView] = {
        return [ self.emailTextField ]
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = self.textField(placeholder: Localize("auth.newDesign.email"))
        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        textField.text = self.email
        return textField
    }()
    
    var canGoBack: Bool {
        return true
    }
    
    var buttonTitle: String? {
        return Localize("auth.newDesign.confirm")
    }
    
    var next: FormController? {
        return SignUpEmailCodeFormController(email: emailTextField.text!)
    }
    
    var segueIdentifier: String? {
        return nil
    }
    
    private var signUpTrigger = PublishSubject<Void>()
    
    lazy var viewModel : SignUpEmailViewModel={
        return SignUpEmailViewModel(submit: self.signUpTrigger.asObservable() )
    }()
    
    private var disposeBag = DisposeBag()
    
    func bind<T>(button: UIButton, nextTrigger: PublishSubject<Void>, pinTrigger: PublishSubject<Pin1ViewController?>, loading: UIBindingObserver<T, Bool>, error: UIBindingObserver<T, [AnyHashable : Any]>) where T : UIViewController {
        disposeBag = DisposeBag()
        
        emailTextField.rx.text
            .filterNil()
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        emailTextField.rx.returnTap
            .map { _ in return button.isEnabled }
            .filterTrueAndBind(toTrigger: signUpTrigger)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .bind(to: signUpTrigger)
            .disposed(by: disposeBag)
        
        viewModel.loading
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.loading
            .bind(to: loading)
            .disposed(by: disposeBag)
        
        let resultObservable = viewModel.result.asObservable()
        
        resultObservable
            .filterError()
            .bind(to: error)
            .disposed(by: disposeBag)
        
        resultObservable
            .filterSuccess()
            .map { _ in return () }
            .bind(to: nextTrigger)
            .disposed(by: disposeBag)
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }
    

}
