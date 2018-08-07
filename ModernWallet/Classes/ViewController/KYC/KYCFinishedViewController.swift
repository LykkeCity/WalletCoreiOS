//
//  KYCFinishedViewController.swift
//  ModernMoney
//
//  Created by Lyubomir Marinov on 31.07.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class KYCFinishedViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = Localize("kyc.success.header")
        message.text = Localize("kyc.success")
        continueButton.setTitle(Localize("kyc.success.okButton"), for: .normal)
    }

    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
