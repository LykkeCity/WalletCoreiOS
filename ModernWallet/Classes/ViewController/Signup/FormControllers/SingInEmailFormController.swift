//
//  SingInEmailFormController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 28.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SingInEmailFormController: FormController {
    
    lazy var formViews: [UIView] = {
        return [self.emailTextField]
    }()
    
    var canGoBack: Bool = false
    
    var buttonTitle: String? = Localize("auth.newDesign.signin")
    
    var next: FormController? {
        return SignInPasswordFormController(email: emailTextField.text!)
    }
    
    var segueIdentifier: String? {
        return nil
    }
    
    lazy private(set) var emailTextField: UITextField = {
        let textField = self.textField(placeholder: Localize("auth.newDesign.email"))
        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        return textField
    }()
    
    private lazy var emailObservable: Observable<String?> = {
        return self.emailTextField.rx.text.asObservable()
            .replaceNilWith("")
            .map{ LWValidator.validateEmail($0) ? $0 : nil }
            .shareReplay(1)
    }()

    private var disposeBag = DisposeBag()
    
    func bind<T>(button: UIButton,
                 nextTrigger: PublishSubject<Void>,
                 recoveryTrigger: PublishSubject<Void>,
                 recoveryPinTrigger: PublishSubject<String>,
                 pinTrigger: PublishSubject<PinViewController?>,
                 loading: UIBindingObserver<T, Bool>,
                 error: UIBindingObserver<T, [AnyHashable : Any]>) where T : UIViewController {
        disposeBag = DisposeBag()
        
        button.setTitle(Localize("auth.newDesign.signin"), for: UIControlState.normal)
        
        emailObservable
            .map { $0 != nil }
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)

        emailTextField.rx.returnTap
            .map { _ in return button.isEnabled }
            .filterTrueAndBind(toTrigger: nextTrigger)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .bind(to: nextTrigger)
            .disposed(by: disposeBag)
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }

}

extension Reactive where Base == UITextField {
    
    var returnTap: ControlEvent<Void> {
        return controlEvent([.editingDidEndOnExit])
    }
    
}
