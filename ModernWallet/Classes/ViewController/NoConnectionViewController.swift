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
            .filter{$0}
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }

}
