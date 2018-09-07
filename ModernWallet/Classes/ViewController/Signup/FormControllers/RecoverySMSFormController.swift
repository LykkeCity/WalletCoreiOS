//
//  RecoverySMSFormController.swift
//  ModernMoney
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class RecoverySMSFormController: RecoveryController {
    
    let recoveryModel: LWRecoveryPasswordModel
    
    private lazy var recoveryModelObservable: Observable<LWRecoveryPasswordModel> = {
       return Observable.just(self.recoveryModel)
    }()
    
    init(recoveryModel: LWRecoveryPasswordModel) {
        self.recoveryModel = recoveryModel
    }
    
    lazy var validationViewModel: ValidateSmsCodeViewModel = {
        return ValidateSmsCodeViewModel()
    }()
    
    lazy var sendSmsViewModel: SendSmsViewModel = {
        return SendSmsViewModel(inputRecoveryModel: self.recoveryModelObservable)
    }()
    
    lazy var confirmSmsViewModel: ConfirmSmsViewModel = {
        return ConfirmSmsViewModel()
    }()
    
    lazy var changePinViewModel: ChangePinViewModel = {
        return ChangePinViewModel()
    }()

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
        return Localize("restore.form.next")
    }
    
    var next: FormController? {
        return nil
    }
    
    var segueIdentifier: String? {
        return nil
    }
    
    var recoveryStep: RecoveryController? {
        return nil
    }
    
    private var smsCheckTrigger = PublishSubject<Void>()
    
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
        
        let smsCodeObservable = smsCodeTextField.rx.text
            .orEmpty
            .shareReplay(1)
        
        smsCodeObservable
            .bind(to: recoveryModel.rx.smsCode)
            .disposed(by: disposeBag)
        
        smsCodeObservable
            .bind(to: validationViewModel.smsCode)
            .disposed(by: disposeBag)
        
        validationViewModel.isSmsCodeValid
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        resendSmsButton.rx.tap
            .bind(to: sendSmsViewModel.smsSendTrigger)
            .disposed(by: disposeBag)
        
        sendSmsViewModel.outputRecoveryModel
            .bind(to: confirmSmsViewModel.inputRecoveryModel)
            .disposed(by: disposeBag)
        
        smsCheckTrigger
            .bindToResignFirstResponder(views: formViews)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .bind(to: smsCheckTrigger)
            .disposed(by: disposeBag)
            
        smsCheckTrigger
            .withLatestFrom(confirmSmsViewModel.outputRecoveryModel)
            .bind(to: changePinViewModel.recoveryModel)
            .disposed(by: disposeBag)
        
        changePinViewModel.isChangeConfirmed
            .bind(to: nextTrigger)
            .disposed(by: disposeBag)
        
        Observable.merge([
            self.sendSmsViewModel.loadingViewModel.isLoading,
            self.confirmSmsViewModel.loadingViewModel.isLoading,
            self.changePinViewModel.loadingViewModel.isLoading
        ])
        .bind(to: loading)
        .disposed(by: disposeBag)
        
        changePinViewModel.errors
            .bind(to: error)
            .disposed(by: disposeBag)
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }

}
