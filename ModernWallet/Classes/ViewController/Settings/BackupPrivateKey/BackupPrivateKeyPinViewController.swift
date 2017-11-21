//
//  BackupPrivateKeyPinViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 20.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class BackupPrivateKeyPinViewController: UIViewController {
    
    @IBOutlet private weak var messageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        messageLabel.text = Localize("backup.newDesign.forAdditionalSecurity")
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedPin" {
            (segue.destination as? PinViewController)?.delegate = self
        }
    }

}

extension BackupPrivateKeyPinViewController: PinViewControllerDelegate {
    
    func isPinCorrect(_ success: Bool, pinController: PinViewController) {
        guard success else {
            return
        }
        performSegue(withIdentifier: "ShowWords", sender: nil)
    }
    
    func isTouchIdCorrect(_ success: Bool, pinController: PinViewController) {
        guard success else {
            return
        }
        performSegue(withIdentifier: "ShowWords", sender: nil)
    }
    
}
