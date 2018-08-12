//
//  SignUpPasswordHintFormController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 29.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SignUpPasswordHintFormController: FormController {
    
    let email: String
    
    let password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
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
    
    #if TEST
    private var testLoadingViewModel: LoadingViewModel?
    #endif
    
    var canGoBack: Bool {
        return true
    }
    
    var buttonTitle: String? {
        return Localize("auth.newDesign.next")
    }
    
    var next: FormController? {
        return SignUpFillProfileFormController(email: self.email)
    }
    
    var segueIdentifier: String? {
        return nil
    }
    
    private let registrationTrigger = PublishSubject<Void>()
    
    private lazy var viewModel : SignUpRegistrationViewModel={
        let viewModel = SignUpRegistrationViewModel(submit: self.registrationTrigger.asObservable())
        viewModel.clientInfo.value = LWDeviceInfo.instance().clientInfo()
        viewModel.email.value = self.email
        viewModel.password.value = self.password
        return viewModel
    }()

    private var disposeBag = DisposeBag()
    
    func bind<T>(button: UIButton, nextTrigger: PublishSubject<Void>, recoveryTrigger: PublishSubject<Void>, pinTrigger: PublishSubject<PinViewController?>, loading: UIBindingObserver<T, Bool>, error: UIBindingObserver<T, [AnyHashable : Any]>) where T : UIViewController {
        disposeBag = DisposeBag()
        
        hintTextField.rx.text
            .filterNil()
            .bind(to: viewModel.hint)
            .disposed(by: disposeBag)
        
        viewModel.isValidHint
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterError()
            .bind(to: error)
            .disposed(by: disposeBag)

        #if TEST
            
            let allAssetRequest = viewModel.result.asObservable()
                .filterSuccess()
                .flatMap { _ in
                    return LWRxAuthManager.instance.allAssets.request()
                }
                .shareReplay(1)
            
            let setBaseAssetRequest = allAssetRequest
                .filterSuccess()
                .map { (assets) in
                    return assets.filter { $0.displayId == "USD" }.first?.identity ?? "USD"
                }
                .flatMap { assetId in
                    LWRxAuthManager.instance.baseAssetSet.request(withParams: assetId)
                }
                .shareReplay(1)
            
            testLoadingViewModel = LoadingViewModel([
                viewModel.loading,
                allAssetRequest.isLoading(),
                setBaseAssetRequest.isLoading()
            ])
            
            testLoadingViewModel?.isLoading
                .asDriver(onErrorJustReturn: false)
                .drive(onNext: { button.isEnabled = !$0 })
                .disposed(by: disposeBag)
            
            testLoadingViewModel?.isLoading
                .bind(to: loading)
                .disposed(by: disposeBag)

            // use zip in order to wait till loading for all above three calls has finished before going to next screen.
            Observable.zip(
                testLoadingViewModel!.isLoading.filter{ !$0 },
                setBaseAssetRequest.filter{ !$0.isLoading }
            ) { _,_ in Void() }
            .bind(to: nextTrigger)
            .disposed(by: disposeBag)
            
        #else
            
            viewModel.result.asObservable()
                .filterSuccess()
                .map { _ in return () }
                .bind(to: nextTrigger)
                .disposed(by: disposeBag)

            viewModel.loading
                .asDriver(onErrorJustReturn: false)
                .drive(onNext: { button.isEnabled = !$0 })
                .disposed(by: disposeBag)

            viewModel.loading
                .bind(to: loading)
                .disposed(by: disposeBag)
        #endif
        
        hintTextField.rx.returnTap
            .withLatestFrom(viewModel.isValidHint)
            .filterTrueAndBind(toTrigger: registrationTrigger)
            .disposed(by: disposeBag)
        
        registrationTrigger
            .bindToResignFirstResponder(views: formViews)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .bind(to: registrationTrigger)
            .disposed(by: disposeBag)
    }
    
    func unbind() {
        disposeBag = DisposeBag()
    }
    
}
