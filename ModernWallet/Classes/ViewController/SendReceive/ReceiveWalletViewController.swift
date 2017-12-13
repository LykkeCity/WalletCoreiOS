//
//  ReceiveWalletViewController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 7.12.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore
import Toast

class ReceiveWalletViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var assetIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!

    var asset: Variable<Asset>!
    
    var address: String!
    
    private let disposeBag = DisposeBag()

    override var modalPresentationStyle: UIModalPresentationStyle {
        get { return .custom }
        set {}
    }
    
    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get { return self }
        set {}
    }
    
    override var preferredContentSize: CGSize {
        get { return CGSize(width: max(Display.width - 60.0, 300.0), height: 440.0) }
        set {}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.setShadow(radius: 4.0, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), opacity: 0.5, offset: CGSize(width: 0, height: 2))
        
        emailButton.setTitle(Localize("receive.newDesign.email"), for: .normal)
        copyButton.setTitle(Localize("receive.newDesign.copy"), for: .normal)
        shareButton.setTitle(Localize("receive.newDesign.share"), for: .normal)

        let walletAsset = asset.value.wallet?.asset
        if let iconUrl = walletAsset?.iconUrl {
            assetIconImageView.af_setTemplateImage(withURL: iconUrl, useToken: false)
        }
        
        let format = Localize("receive.newDesign.receivingAddressFmt")!
        titleLabel.text = String(format: format, walletAsset?.displayName ?? "").trimmingCharacters(in: .whitespaces)
        
        qrCodeImageView.image = UIImage.generateQRCode(
            fromString: address,
            withSize: qrCodeImageView.frame.size,
            color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        )
        
        let sendEmailObservable = emailButton.rx.tap.asObservable()
            .flatMap { [weak emailButton, walletAsset, address] (_) -> Observable<ApiResult<LWPacketSendBlockchainEmail>> in
                emailButton?.isEnabled = false
                guard let asset = walletAsset, let address = address else {
                    return Observable.empty()
                }
                let params: LWRxAuthManagerSendBlockchainEmail.RequestParams
                if asset.identity == "SLR" {
                    params = (assetId: asset.identity, address: "")
                }
                else {
                    params = (assetId: asset.identity ?? asset.issuerId, address: address)
                }
                return LWRxAuthManager.instance.sendBlockchainEmail.request(withParams: params)
            }
            .shareReplay(1)
        
        sendEmailObservable.isLoading().map { !$0 }
            .asDriver(onErrorJustReturn: false)
            .drive(emailButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        sendEmailObservable.filterSuccess()
            .map { _ in return Localize("receive.newDesign.emailToast") }
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [weak view] message in view?.makeToast(message) })
            .disposed(by: disposeBag)
        
        sendEmailObservable.filterError()
            .asDriver(onErrorJustReturn: [:])
            .drive(rx.error)
            .disposed(by: disposeBag)
        
        addressLabel.text = address
    }

    // MARK: - IBActions
    
    @IBAction func closeTapped() {
        dismiss(animated: true)
    }
    
    @IBAction func copyTapped() {
        UIPasteboard.general.string = address
        view.makeToast(Localize("receive.newDesign.copyToast"))
    }
    
    @IBAction func shareTapped() {
        shareButton.isEnabled = false
        let messageFormat = Localize("receive.newDesign.shareMessageFmt") ?? "%@ %@"
        let message = String(format: messageFormat, asset.value.wallet?.asset.displayId ?? "", address)
        var items: [Any] = [message.replacingOccurrences(of: "  ", with: " ")]
        if let qrCodeImage = qrCodeImageView.image {
            items.append(qrCodeImage)
        }
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.excludedActivityTypes = [.addToReadingList, .assignToContact, .print, UIActivityType("com.apple.CloudDocsUI.AddToiCloudDrive")]
        activityController.completionWithItemsHandler = { [weak view, weak shareButton] (type, success, items, error) in
            shareButton?.isEnabled = true
            if success {
                view?.makeToast(Localize("receive.newDesign.shareToast"))
            }
            else {
                view?.makeToast(error?.localizedDescription)
            }
        }
        present(activityController, animated: true)
    }

}

extension ReceiveWalletViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CenteredAnimatedTransitioning(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CenteredAnimatedTransitioning(presenting: false)
    }
    
}

class CenteredAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let presenting: Bool
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if presenting {
            guard
                let viewController = transitionContext.viewController(forKey: .to),
                let view = viewController.view
            else { return }
            containerView.addSubview(view)
            let containerBounds = containerView.bounds
            var frame = containerBounds
            frame.origin.y = (frame.height + viewController.preferredContentSize.height) / 2.0
            view.frame = frame
            containerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           animations: {
                            view.frame.origin.y = 0.0
                            containerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
            },
                           completion: { _ in
                            transitionContext.completeTransition(true)
            })
        }
        else {
            guard
                let viewController = transitionContext.viewController(forKey: .from),
                let view = viewController.view
            else { return }
            containerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
            let y = (containerView.bounds.height + viewController.preferredContentSize.height) / 2.0
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           animations: {
                            view.frame.origin.y = y
                            containerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            },
                           completion: { _ in
                            transitionContext.completeTransition(true)
            })
        }
    }
    
}
