//
//  SignUpSetPasswordFormController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 29.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SignUpSetPasswordFormController: FormController {
    
    let email: String
    
    init(email: String) {
        self.email = email
    }
    
    lazy var formViews: [UIView] = {
        return [
            self.titleLabel(title: Localize("auth.newDesign.createPassword")),
            self.passwordTextField,
            self.reenterPassTextField
        ]
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = self.textField(placeholder: Localize("auth.newDesign.enterPassword"))
        textField.isSecureTextEntry = true
        textField.returnKeyType = .next
        return textField
    }()
    
    private lazy var reenterPassTextField: UITextField = {
        let textField = self.textField(placeholder: Localize("auth.newDesign.enterAgain"))
        textField.isSecureTextEntry = true
        textField.returnKeyType = .next
        return textField
    }()
    
    var canGoBack: Bool {
        return false
    }
    
    var buttonTitle: String? {
        return Localize("auth.newDesign.next")
    }
    
    var next: FormController? {
        return SignUpPasswordHintFormController(email: email, password: passwordTextField.text!)
    }
    
    var segueIdentifier: String? {
        return nil
    }
    
    lazy var viewModel : SignUpRegistrationViewModel={
        return SignUpRegistrationViewModel(submit: Observable.never() )
    }()
    
    private var disposeBag = DisposeBag()
    
    func bind<T>(button: UIButton, nextTrigger: PublishSubject<Void>, pinTrigger: PublishSubject<PinViewController?>, loading: UIBindingObserver<T, Bool>, error: UIBindingObserver<T, [AnyHashable : Any]>) where T : UIViewController {
        disposeBag = DisposeBag()
        
        passwordTextField.rx.text
            .filterNil()
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.returnTap
            .subscribe(onNext: { _ in
                self.reenterPassTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        reenterPassTextField.rx.text
            .filterNil()
            .bind(to: viewModel.reenterPassword)
            .disposed(by: disposeBag)
        
        reenterPassTextField.rx.returnTap
            .withLatestFrom(viewModel.isValid.asObservable())
            .filterTrueAndBind(toTrigger: nextTrigger)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)

        button.rx.tap
            .bind(to: nextTrigger)
            .disposed(by: disposeBag)
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }
    
}
