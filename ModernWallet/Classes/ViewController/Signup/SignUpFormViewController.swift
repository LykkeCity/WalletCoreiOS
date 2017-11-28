//
//  SignUpFormViewController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 28.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift

class SignUpFormViewController: UIViewController {
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var leftStackView: UIStackView!
    @IBOutlet private weak var rightStackView: UIStackView!
    @IBOutlet private weak var submitButton: UIButton!
    
    @IBOutlet private weak var leftStackCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leftStackBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightStackCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightStackBottomConstraint: NSLayoutConstraint!

    private var forms = [FormController]()
    
    private var nextTrigger = PublishSubject<Void>()
    
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
    }
    
    // MARK: - IBActions
    
    @IBAction private func backTapped() {
        popFormController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    }
    
    func push(formController: FormController, animated: Bool) {
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
        formController.bind(button: submitButton, nextTrigger: nextTrigger, loading: rx.loading, error: rx.error)
        forms.append(formController)
    }
    
    func popFormController(animated: Bool) {
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
        previousFormController.bind(button: submitButton, nextTrigger: nextTrigger, loading: rx.loading, error: rx.error)
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
