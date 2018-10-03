//
//  SignInEmailVerificationFormController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 29.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SignInEmailVerificationFormController: FormController {

    let email: String
    
    let accessToken: String?
    
    init(email: String, accessToken: String?) {
        self.email = email
        self.accessToken = accessToken
        UserDefaults.standard.tempEmail = email
    }
    
    lazy var formViews: [UIView] = {
        return [
            self.titleLabel(title: Localize("register.email.confirm.subtitle")),
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
        return false
    }
    
    var buttonTitle: String? {
        return Localize("auth.newDesign.confirm")
    }
    
    var next: FormController? {
        return nil
    }
    
    var segueIdentifier: String? {
        return nil
    }
    
    private lazy var sendViewModel: EmailCodeSendViewModel = {
       return EmailCodeSendViewModel(email: self.email)
    }()
    
    private lazy var verifyViewModel: EmailCodeVerifyViewModel = {
       return EmailCodeVerifyViewModel(email: self.email, accessToken: self.accessToken)
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
        
        sendViewModel
            .sendEmailCodeComplete
            .map{ Localize("auth.newDesign.weHaveSentCodeToEmail") }
            .bind(to: toast)
            .disposed(by: disposeBag)
        
        let emailCode = emailCodeTextField.rx.text.orEmpty
            .shareReplay(1)
            
        emailCode
            .map{ $0.count >= 4 }
            .startWith(false)
            .asDriver(onErrorJustReturn: false)
            .drive(button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        emailCode
            .bind(to: verifyViewModel.codeInputSubject)
            .disposed(by: disposeBag)
        
        verifyViewModel
            .encodedPrivateKeySuccess
            .map{ _ in
                SignUpStep.resetInstance()
                UserDefaults.standard.isLoggedIn = true
                UserDefaults.standard.synchronize()
                NotificationCenter.default.post(name: .loggedIn, object: nil)
                return ()
            }
            .bind(to: nextTrigger)
            .disposed(by: disposeBag)
        
        verifyViewModel.loadingViewModel.isLoading
            .observeOn(MainScheduler.instance)
            .bind(to: loading)
            .disposed(by: disposeBag)
        
        verifyViewModel
            .errors
            .bind(to: error)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .bind(to: verifyViewModel.checkCodeTrigger)
            .disposed(by: disposeBag)
        
        resendEmailButton.rx.tap
            .bind(to: sendViewModel.sendEmailCodeTrigger)
            .disposed(by: disposeBag)
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }

}
