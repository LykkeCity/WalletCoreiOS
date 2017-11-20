//
//  BackupPrivateKeyStartViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 20.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class BackupPrivateKeyStartViewController: UIViewController {

    @IBOutlet private weak var makeBackupLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeBackupLabel.text = Localize("backup.newDesign.makeBackup")
        infoLabel.text = Localize("backup.newDesign.backupInfo")
        startButton.setTitle(Localize("backup.newDesign.readyToWrite"), for: .normal)
    }

}
