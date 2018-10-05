//
//  SignInPhoneVerificationFormController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 29.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SignInPhoneVerificationFormController: FormController {

    let phone: String
    
    let email: String
    
    init(phone: String, email: String) {
        self.phone = phone
        self.email = email
        UserDefaults.standard.tempPhone = phone
        UserDefaults.standard.synchronize()
    }
    
    lazy var formViews: [UIView] = {
        return [
            self.titleLabel(title: Localize("register.phone.confirm.subtitle")),
            self.smsCodeTextField,
            self.resendSmsView
        ]
    }()
    
    private lazy var smsCodeTextField: UITextField = {
        let textField = self.textField(placeholder: Localize("auth.newDesign.code"))
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        return textField
    }()
    
    private lazy var resendSmsView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let button = self.resendSmsButton
        view.addSubview(button)
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 60.0))
        view.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        return view
    }()
    
    private lazy var resendSmsButton: UIButton = {
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
        return SignInEmailVerificationFormController(email: self.email, accessToken: self.fetchedAccessToken.value)
    }
    
    var segueIdentifier: String? {
        return nil
    }
    
    private lazy var sendViewModel: PhoneCodeSendViewModel = {
       return PhoneCodeSendViewModel()
    }()
    
    private lazy var verifyViewModel: PhoneCodeVerifyViewModel = {
       return PhoneCodeVerifyViewModel()
    }()
    
    private let fetchedAccessToken = Variable<String?>(nil)
    
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
            .sendSmsCodeComplete
            .map{ Localize("register.phone.sms.sent") }
            .bind(to: toast)
            .disposed(by: disposeBag)
        
        let smsCode = smsCodeTextField.rx.text.orEmpty
            .shareReplay(1)
            
        smsCode
            .map{ $0.count >= 4 }
            .startWith(false)
            .asDriver(onErrorJustReturn: false)
            .drive(button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        smsCode
            .bind(to: verifyViewModel.codeInputSubject)
            .disposed(by: disposeBag)
        
        let accessToken = verifyViewModel
            .accessTokenObservable
            .shareReplay(1)
        
        accessToken
            .bind(to: fetchedAccessToken)
            .disposed(by: disposeBag)
        
        accessToken
            .filterNil()
            .map { _ in () }
            .bind(to: nextTrigger)
            .disposed(by: disposeBag)

        verifyViewModel
            .errors
            .bind(to: error)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .bind(to: verifyViewModel.checkCodeTrigger)
            .disposed(by: disposeBag)

        resendSmsButton.rx.tap
            .bind(to: sendViewModel.sendSmsCodeTrigger)
            .disposed(by: disposeBag)
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }

}
