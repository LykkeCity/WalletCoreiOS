//
//  SignUpFillProfileFormController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 29.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SignUpFillProfileFormController: FormController {
    
    lazy var formViews: [UIView] = {
        return [
            self.titleLabel(title: Localize("auth.newDesign.profileTitle")),
            self.firstNameTextField,
            self.lastNameTextField
        ]
    }()
    
    private lazy var firstNameTextField: UITextField = {
        let textField = self.textField(placeholder: Localize("auth.newDesign.firstName"))
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.returnKeyType = .next
        return textField
    }()
    
    private lazy var lastNameTextField: UITextField = {
        let textField = self.textField(placeholder: Localize("auth.newDesign.lastName"))
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.returnKeyType = .next
        return textField
    }()
    
    var canGoBack: Bool {
        return false
    }
    
    var buttonTitle: String? {
        return Localize("auth.newDesign.next")
    }
    
    var next: FormController? {
        return SignUpFillPhoneFormController()
    }
    
    var segueIdentifier: String? {
        return nil
    }
    
    private let sendFullnameTrigger = PublishSubject<Void>()
    
    private lazy var viewModel : ClientFullNameSetViewModel={
        return ClientFullNameSetViewModel(trigger: self.sendFullnameTrigger.asObservable())
    }()
    
    private var disposeBag = DisposeBag()
    
    func bind<T>(button: UIButton, nextTrigger: PublishSubject<Void>, pinTrigger: PublishSubject<Pin1ViewController?>, loading: UIBindingObserver<T, Bool>, error: UIBindingObserver<T, [AnyHashable : Any]>) where T : UIViewController {
        disposeBag = DisposeBag()
        
        firstNameTextField.rx.text
            .filterNil()
            .bind(to: viewModel.firstName)
            .disposed(by: disposeBag)
        
        firstNameTextField.rx.returnTap
            .bind(onNext: { [lastNameTextField] _ in
                lastNameTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        lastNameTextField.rx.text
            .filterNil()
            .bind(to: viewModel.lastName)
            .disposed(by: disposeBag)
        
        lastNameTextField.rx.returnTap
            .withLatestFrom(viewModel.isValid)
            .filterTrueAndBind(toTrigger: sendFullnameTrigger)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .bind(to: sendFullnameTrigger)
            .disposed(by: disposeBag)
        
        viewModel.loadingViewModel.isLoading
            .bind(to: loading)
            .disposed(by: disposeBag)

        viewModel.isValid
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.clientFullNameSet
            .map { _ in
                loading.onNext(false)
                return ()
            }
            .bind(to: nextTrigger)
            .disposed(by: disposeBag)
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }
    

}
