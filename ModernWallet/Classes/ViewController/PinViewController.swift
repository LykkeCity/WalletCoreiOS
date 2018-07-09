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

class PinViewController: UIViewController {
    
    static var createPinViewController: PinViewController {
        let viewController = PinViewController(nibName: "PinViewController", bundle: nil)
        viewController.mode = .createPin
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = viewController
        return viewController
    }
    
    static var createPinViewControllerWithoutCloseButton: PinViewController {
        let viewController = createPinViewController
        viewController.hideCloseButton = true
        return viewController
    }
    
    static func enterPinViewController(title: String?, isTouchIdEnabled: Bool) -> PinViewController {
        let viewController = PinViewController(nibName: "PinViewController", bundle: nil)
        viewController.mode = .enterPin(isTouchIdEnabled: isTouchIdEnabled)
        viewController.title = title
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = viewController
        return viewController
    }
    
    static func presentPinViewController(from viewController: UIViewController, title: String?, isTouchIdEnabled: Bool) -> Observable<Void> {
        let pinViewController = enterPinViewController(title: title, isTouchIdEnabled: isTouchIdEnabled)
        viewController.present(pinViewController, animated: true)
        return pinViewController.complete
            .filter { $0 }
            .map { _ in return () }
            .shareReplay(1)
    }
    static func presentPinViewControllerWithCompleted(from viewController: UIViewController, title: String?, isTouchIdEnabled: Bool) -> Observable<Bool> {
        let pinViewController = enterPinViewController(title: title, isTouchIdEnabled: isTouchIdEnabled)
        viewController.present(pinViewController, animated: true)
        return pinViewController.complete
            .filter { $0 }
            .shareReplay(1)
    }
    
    static func presentOrderPinViewController(from viewController: UIViewController, title: String?, isTouchIdEnabled: Bool) -> Observable<Void> {
        guard LWCache.instance()?.shouldSignOrder ?? true else {
            return Observable.just(Void())
        }
        return presentPinViewController(from: viewController, title: title, isTouchIdEnabled: isTouchIdEnabled)
    }
    
    static func inactivePinViewController(withTitle title: String?, isTouchIdEnabled: Bool) -> PinViewController {
        let pinViewController = enterPinViewController(title: title, isTouchIdEnabled: isTouchIdEnabled)
        pinViewController.isPresentedForInactivity = true
        
        return pinViewController
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var dotsView: UIStackView!
    @IBOutlet private weak var keyboardView: UIStackView!
    @IBOutlet private var keyboardButtons: [UIButton]!
    @IBOutlet private weak var touchIdButton: UIButton!
    @IBOutlet private weak var forgotPinButton: UIButton!

    var permitedTriesCount = 3
    
    var isPresentedForInactivity: Bool = false
    
    var hideCloseButton: Bool = false
    
    let complete = PublishSubject<Bool>()

    private enum Mode {
        case enterPin(isTouchIdEnabled: Bool)
        case createPin
    }
    
    private var mode: Mode = .enterPin(isTouchIdEnabled: false)
    
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
            .filter{ !$0.isCodeOne }
            .subscribe(self.rx.error)
            .disposed(by: self.disposeBag)
        
        Observable
            .merge(
                result.result.asObservable().filterError().filter{ $0.isCodeOne }.map{ _ in () },
                result.result.asObservable().filterSuccess().map{ _ in () }
            )
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
        
        if case .createPin = mode, SignUpStep.instance?.isNotGenerateWallet ?? false {
            SignUpStep.instance = .setPin
        }

        forgotPinButton.setTitle(Localize("auth.newDesign.forgotPin"), for: UIControlState.normal)
        triesLeftCount = permitedTriesCount
        
        switch mode {
        case .createPin:
            forgotPinButton.isHidden = true
            titleLabel.text = Localize("pin.create.new.title")
            touchIdButton.alpha = 0.0
        case .enterPin(var isTouchIdEnabled):
            titleLabel.text = title
            isTouchIdEnabled = isTouchIdEnabled && LWFingerprintHelper.isFingerprintAvailable()
            touchIdButton.alpha = isTouchIdEnabled ? 1.0 : 0.0
            if isTouchIdEnabled {
                touchIdTapped()
            }
        }

        // Hide the close button action if the view controller is presented due to inactivity
        if isPresentedForInactivity {
            closeButton.isHidden = true
        }
        
        //Hide the close button
        if hideCloseButton {
            closeButton.isHidden = true
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show the NoNetworkViewController on top of the modal PinViewController
        ReachabilityService.instance
            .reachabilityStatus
            .filter{!$0}
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                let noConnectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnection")
                noConnectionViewController.modalTransitionStyle = .crossDissolve
                self?.present(noConnectionViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        reset()
    }
    
    // MARK: - IBActions
    
    @IBAction private func digitTapped(_ digitButton: UIButton) {
        digits.append("\(digitButton.tag)")
        if digits.count == dotsView.subviews.count {
            pinEntered()
        }
    }

    @IBAction private func touchIdTapped() {
        LWFingerprintHelper.validateFingerprintTitle(Localize("auth.validation.fingerpring"), ok: {
            self.dismiss(success: true, animated: true)
        }, bad: {
            print("Something went wrong")
        }) {
            print("Something went wrong")
        }
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
        if triesLeftCount == 0 && !isPresentedForInactivity {
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

extension PinViewController: UIViewControllerTransitioningDelegate {
    
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
