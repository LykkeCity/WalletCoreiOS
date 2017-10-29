//
//  CashOutTotalTableViewCell.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 29.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class CashOutTotalTableViewCell: UITableViewCell {

    @IBOutlet private(set) var totalLabel: UILabel!
    @IBOutlet private(set) var totalAmountView: AssetAmountView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        totalLabel.text = Localize("cashOut.newDesign.total")
    }

}
