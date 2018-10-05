//
//  SignUpConfirmPhoneFormController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 29.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SignUpPhoneVerificationFormController: FormController {

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
            self.titleLabel(title: Localize("auth.newDesign.signUpConfirmPhone")),
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
        return true
    }
    
    var buttonTitle: String? {
        return Localize("auth.newDesign.confirm")
    }
    
    var next: FormController? {
        return nil
    }
    
    var segueIdentifier: String? {
        return "CreateKey"
    }
    
    private var checkPinTrigger = PublishSubject<Void>()
    
    /// View model for register
    private lazy var signUpConfirmPhoneViewModel : SignUpPhoneConfirmPinViewModel = {
        let viewModel =  SignUpPhoneConfirmPinViewModel(submitConfirmPin: self.checkPinTrigger.asObservable(), submitResendPin: self.resendSmsButton.rx.tap.asObservable() )
        viewModel.phone.value = self.phone
        return viewModel
    }()

    
    let smsCodeForRetrieveKey = PublishSubject<String>()
    
    /// view model for login
    lazy var clientCodesViewModel: ClientCodesViewModel = {
        return ClientCodesViewModel(
            email: self.email,
            smsCodeForRetrieveKey: self.smsCodeForRetrieveKey.asObservable(),
            triggerForSMSCode: self.resendSmsButton.rx.tap.asObservable().startWith(()),
            dependency: (
                authManager: LWRxAuthManager.instance,
                keychainManager: LWKeychainManager.instance()
            )
        )
    }()
    
    private var disposeBag = DisposeBag()
    
    let forceShowPin = PublishSubject<Void>()
    
    func bind<T>(button: UIButton,
                 nextTrigger: PublishSubject<Void>,
                 recoveryTrigger: PublishSubject<Void>,
                 recoveryPinTrigger: PublishSubject<String>,
                 pinTrigger: PublishSubject<PinViewController?>,
                 loading: UIBindingObserver<T, Bool>,
                 error: UIBindingObserver<T, [AnyHashable : Any]>,
                 toast: UIBindingObserver<T, String>) where T : UIViewController {
        disposeBag = DisposeBag()
        
        smsCodeTextField.rx.text.asObservable().replaceNilWith("")
            .map{ $0.count >= 4 }
            .startWith(false)
            .asDriver(onErrorJustReturn: false)
            .drive(button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        smsCodeTextField.rx.text
            .filterNil()
            .bind(to: signUpConfirmPhoneViewModel.pin)
            .disposed(by: disposeBag)
        
        smsCodeTextField.rx.returnTap
            .withLatestFrom(signUpConfirmPhoneViewModel.isValid)
            .filterTrueAndBind(toTrigger: checkPinTrigger)
            .disposed(by: disposeBag)
        
        checkPinTrigger
            .bindToResignFirstResponder(views: formViews)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .throttle(1.0, scheduler: MainScheduler.instance)
            .bind(to: checkPinTrigger)
            .disposed(by: disposeBag)
        
        let smsCodePassed = signUpConfirmPhoneViewModel.resultConfirmPin.asObservable()
            .filterSuccess()
            .map{ $0.isPassed }
        
        Observable
            .merge(
                signUpConfirmPhoneViewModel.resultConfirmPin.asObservable().filterError(),
                signUpConfirmPhoneViewModel.resultResendPin.asObservable().filterError(),
                smsCodePassed
                    .filter { !$0 }
                    .map { _ -> [AnyHashable: Any] in return [AnyHashable("Message") : Localize("register.sms.error")] }
            )
            .bind(to: error)
            .disposed(by: disposeBag)
        
        let pinViewControllerObservable = Observable
                .merge(
                     forceShowPin.asObservable(),
                     smsCodePassed.map{ _ in () }
                )
                .map { _ in return PinViewController.createPinViewControllerWithoutCloseButton }
                .shareReplay(1)
        
        signUpConfirmPhoneViewModel.loadingViewModel.isLoading
            .observeOn(MainScheduler.instance)
            .bind(to: loading)
            .disposed(by: disposeBag)
        
        pinViewControllerObservable
            .bind(to: pinTrigger)
            .disposed(by: disposeBag)
        
        let pinResult = pinViewControllerObservable
            .flatMap{ $0.complete }
            .shareReplay(1)
        
        pinResult
            .filterTrueAndBind(toTrigger: nextTrigger)
            .disposed(by: disposeBag)
        
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }
    

}

extension Observable where Element == Bool {
    
    func filterTrueAndBind(toTrigger trigger: PublishSubject<Void>) -> Disposable {
        return filter { $0 }
            .map { _ in return () }
            .bind(to: trigger)
    }
    
    func filterFalseAndBind(toTrigger trigger: PublishSubject<Void>) -> Disposable {
        return filter { !$0 }
            .map { _ in return () }
            .bind(to: trigger)
    }
    
}
