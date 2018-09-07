//
//  SignUpFillPhoneFormController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 29.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SignUpFillPhoneFormController: FormController {
    
    let email: String
    
    init(email: String) {
        self.email = email
    }
    
    lazy var formViews: [UIView] = {
        return [
            self.titleLabel(title: Localize("auth.newDesign.phoneTitle")),
            self.phoneNumberTextField
        ]
    }()
    
    private lazy var phoneNumberTextField: UITextField = {
        let textField = self.textField(placeholder: Localize("auth.newDesign.phoneNumber"))
        textField.keyboardType = .phonePad
        textField.returnKeyType = .next
        return textField
    }()
    
    var canGoBack: Bool {
        return false
    }
    
    var buttonTitle: String? {
        return Localize("auth.newDesign.submit")
    }
    
    var next: FormController? {
        return SignInConfirmPhoneFormController(signIn: false, phone: phoneNumberTextField.text!, email: self.email)
    }
    
    var segueIdentifier: String? {
        return nil
    }
    
    private let sendPhoneTrigger = PublishSubject<Void>()
    
    private lazy var viewModel : PhoneNumberViewModel={
        return PhoneNumberViewModel(saveSubmit: self.sendPhoneTrigger.asObservable() )
    }()
    
    private var disposeBag = DisposeBag()
    
    func bind<T>(button: UIButton,
                 nextTrigger: PublishSubject<Void>,
                 recoveryTrigger: PublishSubject<Void>,
                 recoveryPinTrigger: PublishSubject<String>,
                 pinTrigger: PublishSubject<PinViewController?>,
                 loading: UIBindingObserver<T, Bool>,
                 error: UIBindingObserver<T, [AnyHashable : Any]>,
                 toast: UIBindingObserver<T, String>) where T : UIViewController {
        disposeBag = DisposeBag()
        
        phoneNumberTextField.rx.text
            .filterNil()
            .bind(to: viewModel.phonenumber)
            .disposed(by: disposeBag)
        
        sendPhoneTrigger
            .bindToResignFirstResponder(views: formViews)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .throttle(1.0, scheduler: MainScheduler.instance)
            .bind(to: sendPhoneTrigger)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.loadingSaveChanges
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.loadingSaveChanges
            .bind(to: loading)
            .disposed(by: disposeBag)

        viewModel.saveSettingsResult
            .filterError()
            .bind(to: error)
            .disposed(by: disposeBag)
        
        viewModel.saveSettingsResult
            .filterSuccess()
            .map { _ in return () }
            .bind(to: nextTrigger)
            .disposed(by: disposeBag)
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }
    
}
