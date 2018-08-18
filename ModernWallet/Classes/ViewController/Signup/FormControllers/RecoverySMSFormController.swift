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
    
    let viewModel: RecoveryViewModel
    
    init(viewModel: RecoveryViewModel) {
        self.viewModel = viewModel
    }
    
    lazy var validationViewModel: ValidateSmsCodeViewModel = {
        return ValidateSmsCodeViewModel()
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
    
    private var disposeBag = DisposeBag()
    
    func bind<T>(button: UIButton,
                 nextTrigger: PublishSubject<Void>,
                 recoveryTrigger: PublishSubject<Void>,
                 recoveryPinTrigger: PublishSubject<String>,
                 pinTrigger: PublishSubject<PinViewController?>,
                 loading: UIBindingObserver<T, Bool>,
                 error: UIBindingObserver<T, [AnyHashable : Any]>) where T : UIViewController {
        disposeBag = DisposeBag()
        
        let smsCodeObservable = smsCodeTextField.rx.text
            .orEmpty
            .shareReplay(1)
        
        smsCodeObservable
            .bind(to: viewModel.smsCode)
            .disposed(by: disposeBag)
        
        smsCodeObservable
            .bind(to: validationViewModel.smsCode)
            .disposed(by: disposeBag)
        
        validationViewModel.isSmsCodeValid
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }

}
