//
//  BackupPrivateKeyCompleteViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 23.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class BackupPrivateKeyCompleteViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = Localize("backup.newDesign.completeTitle")
        messageLabel.text = Localize("backup.newDesign.completeMessage")
    }
    
}
