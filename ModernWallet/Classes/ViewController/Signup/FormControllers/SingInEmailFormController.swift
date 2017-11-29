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
        if isEmailRegistered.value {
            return SignInPasswordFormController(email: emailTextField.text!)
        }
        else {
            return SignUpEmailFormController(email: emailTextField.text!)
        }
    }
    
    var segueIdentifier: String? {
        return nil
    }
    
    private lazy var emailTextField: UITextField = {
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
    
    lazy var accountExistsViewModel: AccountExistViewModel = {
        return AccountExistViewModel(email: self.emailObservable.filterNil())
    }()

    private let isEmailRegistered = Variable(false)
    
    private var disposeBag = DisposeBag()
    
    func bind<T: UIViewController>(button: UIButton, nextTrigger: PublishSubject<Void>, pinTrigger: PublishSubject<Pin1ViewController?>, loading: UIBindingObserver<T, Bool>, error: UIBindingObserver<T, [AnyHashable: Any]>) {
        disposeBag = DisposeBag()
        accountExistsViewModel.accountExistObservable
            .do(onNext: { $0.saveValues() })
            .map { $0.isRegistered }
            .bind(to: isEmailRegistered)
            .disposed(by: disposeBag)
            
        isEmailRegistered.asObservable()
            .map{$0 ? "auth.newDesign.signin" : "auth.newDesign.signup"}
            .subscribe(onNext: { [weak button] buttonTitle in
                button?.setTitle(Localize(buttonTitle), for: UIControlState.normal)
            })
            .disposed(by: disposeBag)
        
        accountExistsViewModel.isLoading
            .map{!$0}
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
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
