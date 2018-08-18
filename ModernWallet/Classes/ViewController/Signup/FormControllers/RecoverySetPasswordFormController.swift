//
//  RecoverySetPasswordFormController.swift
//  ModernMoney
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class RecoverySetPasswordFormController: RecoveryController {
    
    let viewModel: RecoveryViewModel
    
    init(viewModel: RecoveryViewModel) {
        self.viewModel = viewModel
    }
    
    lazy var validationViewModel: ValidatePasswordViewModel = {
        return ValidatePasswordViewModel()
    }()
    
    lazy var formViews: [UIView] = {
        return [
            self.titleLabel(title: Localize("auth.newDesign.createPassword")),
            self.passwordTextField,
            self.repeatPasswordTextField,
        ]
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = self.textField(placeholder: Localize("auth.newDesign.enterPassword"))
        textField.isSecureTextEntry = true
        textField.returnKeyType = .next
        return textField
    }()
    
    private lazy var repeatPasswordTextField: UITextField = {
        let textField = self.textField(placeholder: Localize("auth.newDesign.enterAgain"))
        textField.isSecureTextEntry = true
        textField.returnKeyType = .next
        return textField
    }()
    
    var canGoBack: Bool {
        return true
    }
    
    var buttonTitle: String? {
        return Localize("restore.form.next")
    }
    
    var next: FormController? {
        return nil
    }
    
    var segueIdentifier: String? {
        return nil
    }
    
    var recoveryStep: RecoveryController? {
        return RecoverySetHintFormController(viewModel: self.viewModel)
    }
    
    private var disposeBag = DisposeBag()
    
    func bind<T>(button: UIButton,
                 nextTrigger: PublishSubject<Void>,
                 recoveryTrigger: PublishSubject<Void>,
                 recoveryPinTrigger: PublishSubject<String>,
                 pinTrigger: PublishSubject<PinViewController?>,
                 loading: UIBindingObserver<T, Bool>,
                 error: UIBindingObserver<T, [AnyHashable : Any]>) where T : UIViewController {
        disposeBag = DisposeBag()
        
        let passwordObservable = passwordTextField.rx.text
            .orEmpty
            .shareReplay(1)
            
        passwordObservable
            .bind(to: validationViewModel.password)
            .disposed(by: disposeBag)
        
        repeatPasswordTextField.rx.text
            .orEmpty
            .bind(to: validationViewModel.repeatPassword)
            .disposed(by: disposeBag)
        
        validationViewModel.arePasswordsValid
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // Bind empty string to `recoveryPinTrigger` to show the pin view controller
        button.rx.tap
            .map { _ in return () }
            .bind(to: recoveryTrigger)
            .disposed(by: disposeBag)
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }

}
