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
        
        ReachabilityService.instance
            .reachabilityStatus
            .observeOn(MainScheduler.instance)
            .distinctUntilChanged()
            .share()
            .filter{$0}
            .share()
            .subscribe(onNext: { [weak self] value in
                self?.dismiss(animated: true, completion: nil)
                })
            .disposed(by: disposeBag)
    }
}
