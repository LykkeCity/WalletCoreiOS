//
//  PinViewController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 28.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class Pin1ViewController: UIViewController {
    
    static var createPinViewController: Pin1ViewController {
        let viewController = Pin1ViewController(nibName: "Pin1ViewController", bundle: nil)
        viewController.mode = .createPin
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = viewController
        return viewController
    }
    
    static func enterPinViewController(title: String?) -> Pin1ViewController {
        let viewController = Pin1ViewController(nibName: "Pin1ViewController", bundle: nil)
        viewController.mode = .enterPin
        viewController.title = title
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = viewController
        return viewController
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var dotsView: UIStackView!
    @IBOutlet private weak var keyboardView: UIStackView!
    @IBOutlet private var keyboardButtons: [UIButton]!
    @IBOutlet private weak var touchIdButton: UIButton!
    @IBOutlet private weak var forgotPinButton: UIButton!

    var permitedTriesCount = 3
    
    let complete = PublishSubject<Bool>()

    private enum Mode {
        case enterPin
        case createPin
    }
    
    private var mode: Mode = .enterPin
    
    private var triesLeftCount = 3
    
    private var digits = [String]() {
        didSet {
            guard let imageViews = dotsView.subviews as? [UIImageView] else {
                return
            }
            for (index, imageView) in imageViews.enumerated() {
                imageView.isHighlighted = index < digits.count
            }
        }
    }
    
    private var pins = [String]()
    
    private let checkPinTrigger = PublishSubject<Void>()
    
    lazy var checkPinViewModel : PinGetViewModel={
        let result = PinGetViewModel(submit: self.checkPinTrigger.asObservable() )
        result.loading.asDriver(onErrorJustReturn: false)
            .drive(self.rx.loading)
            .disposed(by: self.disposeBag)
        result.result.asObservable().filterError()
            .subscribe(self.rx.error)
            .disposed(by: self.disposeBag)
        result.result.asObservable().filterSuccess()
            .subscribe(onNext: { [weak self] result in
                guard result.isPassed else {
                    self?.shakeAndReset()
                    return
                }
                self?.dismiss(success: true, animated: true)
            })
            .disposed(by: self.disposeBag)
        return result
    }()
    
    private let setPinTrigger = PublishSubject<Void>()

    private lazy var setPinViewModel : SignUpPinSetViewModel={
        let result = SignUpPinSetViewModel(submit: self.setPinTrigger.asObservable())
        result.loading.asDriver(onErrorJustReturn: false)
            .drive(self.rx.loading)
            .disposed(by: self.disposeBag)
        result.result.asObservable().filterError()
            .subscribe(self.rx.error)
            .disposed(by: self.disposeBag)
        result.result.asObservable().filterSuccess()
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(success: true, animated: true)
            })
            .disposed(by: self.disposeBag)
        return result
    }()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        forgotPinButton.setTitle(Localize("auth.newDesign.forgotPin"), for: UIControlState.normal)
        triesLeftCount = permitedTriesCount
        
        switch mode {
        case .createPin:
            forgotPinButton.isHidden = true
            titleLabel.text = Localize("pin.create.new.title")
            touchIdButton.alpha = 0.0
        case .enterPin:
            titleLabel.text = title
            touchIdButton.alpha = LWFingerprintHelper.isFingerprintAvailable() ? 1.0 : 0.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reset()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let backgroundView = closeButton.superview as? BackgroundView else {
            return
        }
        closeButton.isHidden = backgroundView.frame.minY > 10
    }
    
    // MARK: - IBActions
    
    @IBAction private func digitTapped(_ digitButton: UIButton) {
        digits.append("\(digitButton.tag)")
        if digits.count == dotsView.subviews.count {
            pinEntered()
        }
    }

    @IBAction private func touchIdTapped() {
        dismiss(animated: true)
    }
    
    @IBAction private func deleteTapped() {
        guard digits.count > 0 else { return }
        digits.removeLast()
    }
    
    @IBAction private func forgotPinTapped() {
    }
    
    @IBAction private func closeTapped() {
        dismiss(animated: true)
    }
    
    // MARK: Private
    
    private func pinEntered() {
        let pin = digits.joined(separator: "")
        pins.append(pin)
        switch mode {
        case .createPin:
            checkIfPinsMatch()
        case .enterPin:
            checkIsPinCorrect()
        }
    }
    
    private func checkIsPinCorrect() {
        guard pins.count == 1 else {
            return
        }
        let pin = pins[0]
        guard let storedPin = LWKeychainManager.instance()?.pin() else {
            checkPinViewModel.pin.value = pin
            checkPinTrigger.onNext(Void())
            return
        }
        if storedPin == pin {
            dismiss(success: true, animated: true)
        }
        else {
            shakeAndReset()
        }
    }
    
    private func checkIfPinsMatch() {
        guard pins.count == 2 else {
            digits = []
            return
        }
        guard pins[0] == pins[1] else {
            shakeAndReset()
            return
        }
        setPinViewModel.pin.value = pins[0]
        setPinTrigger.onNext(Void())
    }
    
    private func shakeAndReset() {
        shakeKeyboard()
        triesLeftCount -= 1
        if triesLeftCount == 0 {
            dismiss(success: false, animated: true)
            return
        }
        reset()
    }
    
    private func shakeKeyboard() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x:keyboardView.center.x - 10, y:keyboardView.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x:keyboardView.center.x + 10, y:keyboardView.center.y))
        keyboardView.layer.add(animation, forKey: "position")
    }

    private func reset() {
        digits = []
        pins = []
    }
    
    private func dismiss(success: Bool, animated: Bool) {
        complete.onNext(success)
        dismiss(animated: animated)
    }
    
}

extension Pin1ViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PinAnimatedTransitioning(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PinAnimatedTransitioning(presenting: false)
    }
    
}
class PinAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let presenting: Bool
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if presenting {
            guard let view = transitionContext.viewController(forKey: .to)?.view else { return }
            containerView.addSubview(view)
            var frame = containerView.bounds
            frame.origin.y = frame.height
            view.frame = frame
            containerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                animations: {
                    view.frame.origin.y = 0
                    containerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
            },
                completion: { _ in
                    transitionContext.completeTransition(true)
            })
        }
        else {
            guard let view = transitionContext.viewController(forKey: .from)?.view else { return }
            containerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                animations: {
                    view.frame.origin.y = view.frame.height
                    containerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                },
                completion: { _ in
                    transitionContext.completeTransition(true)
                })
        }
    }
}
