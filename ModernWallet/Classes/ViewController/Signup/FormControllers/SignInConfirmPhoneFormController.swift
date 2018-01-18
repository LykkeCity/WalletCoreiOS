//
//  SignInConfirmPhoneFormController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 29.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SignInConfirmPhoneFormController: FormController {
    
    let signIn: Bool
    
    let phone: String
    
    init(signIn: Bool, phone: String) {
        self.signIn = signIn
        self.phone = phone
        UserDefaults.standard.tempPhone = phone
        UserDefaults.standard.synchronize()
    }
    
    lazy var formViews: [UIView] = {
        return [
            self.titleLabel(title: Localize(self.signIn ? "auth.newDesign.signInConfirmPhone" : "auth.newDesign.signUpConfirmPhone")),
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
        return nil
    }
    
    var segueIdentifier: String? {
        return signIn ? nil : "CreateKey"
    }
    
    private var checkPinTrigger = PublishSubject<Void>()
    
    private lazy var viewModel : SignUpPhoneConfirmPinViewModel = {
        let viewModel =  SignUpPhoneConfirmPinViewModel(submitConfirmPin: self.checkPinTrigger.asObservable(), submitResendPin: self.resendSmsButton.rx.tap.asObservable() )
        viewModel.phone.value = self.phone
        return viewModel
    }()
    
    private var getCodesTrigger = PublishSubject<Void>()

    lazy var clientCodes:ClientCodesViewModel = {
        return ClientCodesViewModel(
            trigger: self.getCodesTrigger.asObservable(),
            dependency: (
                authManager: LWRxAuthManager.instance,
                keychainManager: LWKeychainManager.instance()
            )
        )
    }()
    
    lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel([
            self.viewModel.loading,
            self.clientCodes.loadingViewModel.isLoading
        ])
    }()
    
    private var disposeBag = DisposeBag()
    
    let forceShowPin = PublishSubject<Void>()
    
    func bind<T>(button: UIButton, nextTrigger: PublishSubject<Void>, pinTrigger: PublishSubject<PinViewController?>, loading: UIBindingObserver<T, Bool>, error: UIBindingObserver<T, [AnyHashable : Any]>) where T : UIViewController {
        disposeBag = DisposeBag()
        
        smsCodeTextField.rx.text
            .filterNil()
            .bind(to: viewModel.pin)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        smsCodeTextField.rx.returnTap
            .withLatestFrom(viewModel.isValid)
            .filterTrueAndBind(toTrigger: checkPinTrigger)
            .disposed(by: disposeBag)
        
        checkPinTrigger
            .bindToResignFirstResponder(views: formViews)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .bind(to: checkPinTrigger)
            .disposed(by: disposeBag)
        
        viewModel.resultResendPin.asObservable()
            .filterError()
            .bind(to: error)
            .disposed(by: disposeBag)
        
        viewModel.resultConfirmPin.asObservable()
            .filterError()
            .bind(to: error)
            .disposed(by: disposeBag)
        
        let smsCodePassed = viewModel.resultConfirmPin.asObservable()
            .filterSuccess()
            .map { $0.isPassed }
            .shareReplay(1)
        
        smsCodePassed.filter { !$0 }
            .map { _ -> [AnyHashable: Any] in return [AnyHashable("Message") : Localize("register.sms.error")] }
            .bind(to: error)
            .disposed(by: disposeBag)
        
        let shouldGetCodes = smsCodePassed.filter { $0 }
            .map { _ in self.signIn }
            .shareReplay(1)
        
        shouldGetCodes.filter { $0 }
            .map { _ in return () }
            .bind(to: getCodesTrigger)
            .disposed(by: disposeBag)
        
        let pinViewControllerObservable = Observable.merge(
                forceShowPin.asObservable(),
                shouldGetCodes.filter { !$0 }.map{ _ in () }
            )
            .map { _ in return PinViewController.createPinViewController }
            .shareReplay(1)
        
        let pinResult = pinViewControllerObservable
            .flatMap { $0.complete }
            .shareReplay(1)
        
        pinViewControllerObservable
            .bind(to: pinTrigger)
            .disposed(by: disposeBag)
        
        pinResult
            .filterTrueAndBind(toTrigger: nextTrigger)
            .disposed(by: disposeBag)
        
        loadingViewModel.isLoading
            .bind(to: loading)
            .disposed(by: disposeBag)
        
        clientCodes.errors
            .bind(to: error)
            .disposed(by: disposeBag)
        
        Observable.zip(
                clientCodes.loadingViewModel.isLoading.filter{ !$0 },
                clientCodes.encodeMainKeyObservable
            )
            .map { _, _ in
                SignUpStep.resetInstance()
                UserDefaults.standard.isLoggedIn = true
                UserDefaults.standard.synchronize()
                NotificationCenter.default.post(name: .loggedIn, object: nil)
                return ()
            }
            .bind(to: nextTrigger)
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
