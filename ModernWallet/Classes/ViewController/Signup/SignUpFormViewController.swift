//
//  SignUpFormViewController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 28.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import WalletCore

class SignUpFormViewController: UIViewController {
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var leftStackView: UIStackView!
    @IBOutlet private weak var rightStackView: UIStackView!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    
    @IBOutlet private weak var leftStackCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leftStackBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightStackCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightStackBottomConstraint: NSLayoutConstraint!

    private var forms = [FormController]()
    
    private var nextTrigger = PublishSubject<Void>()
    
    private var pinTrigger = PublishSubject<PinViewController?>()
    
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        push(formController: SingInEmailFormController(), animated: false)
        
        scrollView.subscribeKeyBoard(withDisposeBag: disposeBag)
        
        nextTrigger.asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.gotoNext()
            })
            .disposed(by: disposeBag)
        
        pinTrigger.asDriver(onErrorJustReturn: nil)
            .filterNil()
            .drive(onNext: { [weak self] pinViewController in
                self?.present(pinViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        SignUpStep.instance?.initializeFormController()
            .bind(toViewController: self)
            .disposed(by: disposeBag)
    }
    
    // MARK: - IBActions
    
    @IBAction private func backTapped() {
        popFormController(animated: true)
    }
    
    @IBAction private func registerTapped(_ sender: Any) {
        guard let signInEmailForm = forms.last as? SingInEmailFormController else {
            return
        }
        
        let email = signInEmailForm.emailTextField.text ?? ""
        push(formController: SignUpEmailFormController(email: email), animated: true)
    }
    
    // MARK: - Private
    
    func gotoNext() {
        guard let formController = forms.last else {
            return
        }
        if let nextFormController = formController.next {
            push(formController: nextFormController, animated: true)
        }
        else if let segueIdentifier = formController.segueIdentifier {
            performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
        else {
            navigationController?.dismiss(animated: true)
        }
    }

    private func didPush() {
        SignUpStep.instance = SignUpStep.initFrom(formController: forms.last)
    }
    
    private func willPush() {
        registerButton.isHidden = forms.isNotEmpty
    }
    
    private func didPop() {
        SignUpStep.instance = SignUpStep.initFrom(formController: forms.last)
        registerButton.isHidden = forms.count > 1
    }
    
    private func willPop() {
        
    }
    
    func push(formController: FormController, animated: Bool) {
        willPush()
        
        if !animated {
            leftStackView.removeAllSubviews()
            rightStackView.setSubviews(formController.formViews)
            setRightStackViewAtCenter()
            setStackViews(rightVisible: true)
            setBackVisible(formController.canGoBack)
            self.view.layoutIfNeeded()
        }
        else {
            rightStackView.setSubviews(formController.formViews)
            if let leftViews = forms.last?.formViews {
                leftStackView.setSubviews(leftViews)
            }
            setLeftStackViewAtCenter()
            setStackViews(rightVisible: false)
            self.view.layoutIfNeeded()
            setRightStackViewAtCenter()
            UIView.animate(withDuration: 0.3, animations: {
                self.setBackVisible(formController.canGoBack)
                self.view.layoutIfNeeded()
                self.setStackViews(rightVisible: true)
            }, completion: { _ in
                self.leftStackView.removeAllSubviews()
            })
        }
        if let previuosFormController = forms.last {
            previuosFormController.unbind()
        }
        formController.bind(button: submitButton, nextTrigger: nextTrigger, pinTrigger: pinTrigger, loading: rx.loading, error: rx.error)
        submitButton.setTitle(formController.buttonTitle, for: .normal)
        forms.append(formController)
        
        didPush()
    }
    
    func popFormController(animated: Bool) {
        willPop()
        
        guard forms.count > 1 else {
            return
        }
        
        let currentFormContrller = forms.removeLast()
        let previousFormController = forms.last!
        if !animated {
            leftStackView.removeAllSubviews()
            rightStackView.setSubviews(previousFormController.formViews)
            setRightStackViewAtCenter()
            setStackViews(rightVisible: true)
            setBackVisible(previousFormController.canGoBack)
            self.view.layoutIfNeeded()
        }
        else {
            leftStackView.setSubviews(previousFormController.formViews)
            rightStackView.setSubviews(currentFormContrller.formViews)
            setRightStackViewAtCenter()
            setStackViews(rightVisible: true)
            self.view.layoutIfNeeded()
            setLeftStackViewAtCenter()
            UIView.animate(withDuration: 0.3, animations: {
                self.setBackVisible(previousFormController.canGoBack)
                self.view.layoutIfNeeded()
                self.setStackViews(rightVisible: false)
            }, completion: { _ in
                self.leftStackView.removeAllSubviews()
                self.rightStackView.setSubviews(previousFormController.formViews)
                self.setRightStackViewAtCenter()
                self.setStackViews(rightVisible: true)
                self.view.layoutIfNeeded()
            })
        }
        currentFormContrller.unbind()
        previousFormController.bind(button: submitButton, nextTrigger: nextTrigger, pinTrigger: pinTrigger, loading: rx.loading, error: rx.error)
        submitButton.setTitle(previousFormController.buttonTitle, for: .normal)
        
        didPop()
    }
    
    private func setBackVisible(_ visible: Bool) {
        backButton.alpha = visible ? 1.0 : 0.0
    }
    
    private func setStackViews(rightVisible visible: Bool) {
        leftStackView.alpha = visible ? 0.0 : 1.0
        rightStackView.alpha = visible ? 1.0 : 0.0
    }
    
    private func setLeftStackViewAtCenter() {
        rightStackCenterConstraint.isActive = false
        rightStackBottomConstraint.isActive = false
        leftStackCenterConstraint.isActive = true
        leftStackBottomConstraint.isActive = true
    }
    
    private func setRightStackViewAtCenter() {
        leftStackCenterConstraint.isActive = false
        leftStackBottomConstraint.isActive = false
        rightStackCenterConstraint.isActive = true
        rightStackBottomConstraint.isActive = true
    }
}

extension UIStackView {
    
    func setSubviews(_ views: [UIView]) {
        removeAllSubviews()
        views.forEach { self.addArrangedSubview($0) }
    }
    
    func removeAllSubviews() {
        let views = arrangedSubviews
        views.forEach {
            self.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
}

fileprivate extension ObservableType where Self.E == ApiResult<SignUpStep.ControllerResult?> {
    func bind(toViewController vc: SignUpFormViewController) -> [Disposable] {
        return [
            isLoading().bind(to: vc.rx.loading),
            filterSuccess().filterNil().subscribe(onNext: { [weak vc] controllerResult in
                if let formController = controllerResult.formController {
                    vc?.push(formController: formController, animated: true)
                    
                    if controllerResult.showPin, let confirmPhoneFormController = formController as? SignInConfirmPhoneFormController {
                        confirmPhoneFormController.forceShowPin.onNext(())
                    }
                }
                
                if let viewController = controllerResult.viewController {
                    vc?.navigationController?.pushViewController(viewController, animated: false)
                }
            })
        ]
    }
}
