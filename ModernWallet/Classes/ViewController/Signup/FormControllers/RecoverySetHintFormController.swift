//
//  RecoverySetHintFormController.swift
//  ModernMoney
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class RecoverySetHintFormController: RecoveryController {
    
    let viewModel: RecoveryViewModel
    
    init(viewModel: RecoveryViewModel) {
        self.viewModel = viewModel
    }
    
    lazy var validationViewModel: ValidateHintViewModel = {
        return ValidateHintViewModel()
    }()
    
    lazy var formViews: [UIView] = {
        return [
            self.titleLabel(title: Localize("auth.newDesign.hintTitle")),
            self.hintTextField
        ]
    }()
    
    private lazy var hintTextField: UITextField = {
        let textField = self.textField(placeholder: Localize("auth.newDesign.enterHint"))
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .sentences
        textField.returnKeyType = .next
        return textField
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
        return RecoverySMSFormController(viewModel: self.viewModel)
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
        
        let hintObservable = hintTextField.rx.text
            .orEmpty
            .shareReplay(1)
        
        hintObservable
            .bind(to: viewModel.hint)
            .disposed(by: disposeBag)
        
        hintObservable
            .bind(to: validationViewModel.hint)
            .disposed(by: disposeBag)
        
        validationViewModel.isHintValid
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // Bind empty string to `recoveryPinTrigger` to show the pin view controller
        button.rx.tap
            .map { _ in return "" }
            .bind(to: recoveryPinTrigger.asObserver())
            .disposed(by: disposeBag)
        
        // Observe `recoveryPinTrigger` to get the pin (if valid)
        let pinTriggered = recoveryPinTrigger.asObservable()
            .filter { $0.isNotEmpty }
            .shareReplay(1)
        
        pinTriggered
            .bind(to: viewModel.pin)
            .disposed(by: disposeBag)
        
        pinTriggered
            .map { _ in return () }
            .bind(to: recoveryTrigger)
            .disposed(by: disposeBag)
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }

}
