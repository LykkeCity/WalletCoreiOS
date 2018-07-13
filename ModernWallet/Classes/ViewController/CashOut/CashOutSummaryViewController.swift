//
//  CashOutSummaryViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 5.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class CashOutSummaryViewController: UIViewController {
    
    @IBOutlet private weak var successLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var waitMessageLabel: UILabel!
    @IBOutlet private weak var amountView: AssetAmountView!
    @IBOutlet private weak var bankNameTitleLabel: UILabel!
    @IBOutlet private weak var bankNameLabel: UILabel!
    @IBOutlet private weak var ibanTitleLabel: UILabel!
    @IBOutlet private weak var ibanLabel: UILabel!
    @IBOutlet private weak var bicTitleLabel: UILabel!
    @IBOutlet private weak var bicLabel: UILabel!
    @IBOutlet private weak var accountHolderTitleLabel: UILabel!
    @IBOutlet private weak var accountHolderLabel: UILabel!
    @IBOutlet private weak var accountHolderCountryTitleLabel: UILabel!
    @IBOutlet private weak var accountHolderCountryLabel: UILabel!
    @IBOutlet private weak var accountHolderCountryCodeTitleLabel: UILabel!
    @IBOutlet private weak var accountHolderCountryCodeLabel: UILabel!
    @IBOutlet private weak var accountHolderZipCodeTitleLabel: UILabel!
    @IBOutlet private weak var accountHolderZipCodeLabel: UILabel!
    @IBOutlet private weak var accountHolderCityTitleLabel: UILabel!
    @IBOutlet private weak var accountHolderCityLabel: UILabel!
    @IBOutlet private weak var button: UIButton!
    
    var result: LWModelCashOutSwiftResult!

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        
        setResultToLabels()
    }
    
    private func localize() {
        successLabel.text = Localize("cashOut.newDesign.success")
        detailsLabel.text = Localize("cashOut.newDesign.transactionDetails")
        waitMessageLabel.text = Localize("cashOut.newDesign.waitMessage")
        bankNameTitleLabel.text = Localize("cashOut.newDesign.bankName")
        ibanTitleLabel.text = Localize("cashOut.newDesign.iban")
        bicTitleLabel.text = Localize("cashOut.newDesign.bic")
        accountHolderTitleLabel.text = Localize("cashOut.newDesign.accHolder")
        accountHolderCountryTitleLabel.text = Localize("cashOut.newDesign.accHolderCountry")
        accountHolderCountryCodeTitleLabel.text = Localize("cashOut.newDesign.accHolderCountryCode")
        accountHolderZipCodeTitleLabel.text = Localize("cashOut.newDesign.accHolderZipCode")
        accountHolderCityTitleLabel.text = Localize("cashOut.newDesign.accHolderCity")
        button.setTitle(Localize("cashOut.newDesign.backToPortfolio"), for: .normal)
    }
    
    private func setResultToLabels() {
        amountView.amount = result.amount
        amountView.code = result.asset
        bankNameLabel.text = result.bankName
        ibanLabel.text = result.iban
        bicLabel.text = result.bic
        accountHolderLabel.text = result.accountHolder
        accountHolderCountryLabel.text = result.accountHolderCountry
        accountHolderCountryCodeLabel.text = result.accountHolderCountryCode
        accountHolderZipCodeLabel.text = result.accountHolderZipCode
        accountHolderCityLabel.text = result.accountHolderCity
    }

}
