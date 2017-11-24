//
//  EmptyWalletViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 24.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class EmptyWalletViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var button: UIButton!
    
    var message: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = Localize("emptyWallet.newDesign.title")
        messageLabel.text = message
        titleLabel.text = Localize("menu.newDesign.addMoney")
    }

}
