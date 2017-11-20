//
//  BackupPrivateKeyViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 20.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class BackupPrivateKeyViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = Localize("settings.newDesign.backupPrivateKey")
    }
    
    // MARK: IBActions
    
    @IBAction func closeTapped() {
        dismiss(animated: true)
    }

}
