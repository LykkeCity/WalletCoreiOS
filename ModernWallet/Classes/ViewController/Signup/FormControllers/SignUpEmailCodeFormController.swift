//
//  SignUpEmailCodeFormController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 29.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SignUpEmailCodeFormController: FormController {
    
    let email: String
    
    init(email: String) {
        self.email = email
        UserDefaults.standard.tempEmail = email
        UserDefaults.standard.synchronize()
    }
    
    lazy var formViews: [UIView] = {
        return [
            self.titleLabel(title: "\(Localize("auth.newDesign.weHaveSentCodeToEmail") ?? "") \(self.email)"),
            self.emailCodeTextField,
            self.resendEmailView
        ]
    }()
    
    private lazy var emailCodeTextField: UITextField = {
        let textField = self.textField(placeholder: Localize("auth.newDesign.code"))
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        return textField
    }()
    
    private lazy var resendEmailView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let button = self.resendEmailButton
        view.addSubview(button)
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 60.0))
        view.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        return view
    }()
    
    private lazy var resendEmailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localize("auth.newDesign.resendCode"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Geomanist", size: 14.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        return button
    }()

    var canGoBack: Bool {
        return true
    }
    
    var buttonTitle: String? {
        return Localize("auth.newDesign.confirm")
    }
    
    var next: FormController? {
        return SignUpSetPasswordFormController(email: email)
    }
    
    var segueIdentifier: String? {
        return nil
    }
    
    private var checkCodeTrigger = PublishSubject<Void>()
    
    lazy var viewModel : RegisterSendPinEmailViewModel={
        let viewModel = RegisterSendPinEmailViewModel(submitConfirmPin: self.checkCodeTrigger.asObservable(), submitResendPin: self.resendEmailButton.rx.tap.asObservable() )
        viewModel.email.value = self.email
        return viewModel
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
        
        emailCodeTextField.rx.text
            .filterNil()
            .bind(to: viewModel.pin)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.loading.subscribe(onNext: {isLoading in
            button.isEnabled = !isLoading
            self.resendEmailButton.isEnabled = !isLoading
        }).disposed(by: disposeBag)
        
        viewModel.loading
            .bind(to: loading)
            .disposed(by: disposeBag)
        
        viewModel.resultResendPin.asObservable()
            .filterError()
            .bind(to: error)
            .disposed(by: disposeBag)
        
        checkCodeTrigger
            .bindToResignFirstResponder(views: formViews)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .bind(to: checkCodeTrigger)
            .disposed(by: disposeBag)
        
        viewModel.resultConfirmPin.asObservable()
            .filterError()
            .bind(to: error)
            .disposed(by: disposeBag)
        
        let emailCodePassed = viewModel.resultConfirmPin.asObservable()
            .filterSuccess()
            .map { $0.isPassed }
            .shareReplay(1)
        
        emailCodePassed.filter { !$0 }
            .map { _ -> [AnyHashable: Any] in return [AnyHashable("Message") : Localize("register.sms.error")] }
            .bind(to: error)
            .disposed(by: disposeBag)
        
        emailCodePassed
            .waitFor(viewModel.loading)
            .filterTrueAndBind(toTrigger: nextTrigger)
            .disposed(by: disposeBag)
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }
    
}
