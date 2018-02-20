//
//  NoConnectionViewController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 30.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift

class NoConnectionViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var reloadButton: UIButton!

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = Localize("noNetwork.newDesign.title")
        subtitleLabel.text = Localize("noNetwork.newDesign.subtitle")
        reloadButton.setTitle(Localize("noNetwork.newDesign.reload"), for: .normal)

        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(self.showNoInternetIfNeeded(_:)),
            name: NSNotification.Name(rawValue: kNotificationGDXNetAdapterDidFailRequest),
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(self.hideNoInternetConnection),
            name: NSNotification.Name(rawValue: kNotificationGDXNetAdapterDidReceiveResponse),
            object: nil
        )
        
        ReachabilityService.instance
            .reachabilityStatus
            .filter{$0}
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func reloadTapped() {
        reloadButton.isEnabled = false
        LWAuthManager.instance().requestAPIVersion()
        ReloadTrigger.instance.reload()
    }

    @objc private func showNoInternetIfNeeded(_ notification: Notification) {
        guard let ctx = notification.userInfo?[kNotificationKeyGDXNetContext] as? GDXRESTContext else { return }
        guard let error = ctx.error as NSError?, error.domain == NSURLErrorDomain else { return }
        reloadButton.isEnabled = true
    }
    
    @objc private func hideNoInternetConnection() {
        dismiss(animated: true)
    }

}
