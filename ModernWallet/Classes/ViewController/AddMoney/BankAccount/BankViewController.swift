//
//  BankViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/28/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class BankViewController: UIViewController {
    
    @IBOutlet weak var bicLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var purposeOfPaymentLabel: UILabel!
    @IBOutlet weak var bankAddressLabel: UILabel!
    @IBOutlet weak var companyAddressLabel: UILabel!
    
    @IBOutlet weak var bicLbl: UILabel!
    @IBOutlet weak var accountNumberLbl: UILabel!
    @IBOutlet weak var accountNameLbl: UILabel!
    @IBOutlet weak var purposeOfPaymentLbl: UILabel!
    @IBOutlet weak var bankAddressLbl: UILabel!
    @IBOutlet weak var companyAddressLbl: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var fallbackAssetId = "USD"
    
    
    /// If base asset is missing or empty fallback to fallbackAssetId
    var baseAssetId: String {
        guard let baseAsset = LWCache.instance().baseAssetId else {
            return self.fallbackAssetId
        }
        
        return baseAsset.isNotEmpty ? baseAsset : self.fallbackAssetId
    }
    
    /// Swift credentials accoring baseAssetId
    var swiftCredentials: LWSwiftCredentialsModel? {
        let cacheInstance = LWCache.instance()
        
        guard let swiftCredentials = cacheInstance?.swiftCredentialsDict[self.baseAssetId] as? LWSwiftCredentialsModel else {
            return cacheInstance?.swiftCredentialsDict[self.fallbackAssetId] as? LWSwiftCredentialsModel
        }
        
        return swiftCredentials
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.clear
        
        bicLbl.text = Localize("addMoney.newDesign.bankaccount.bic")
        accountNumberLbl.text = Localize("addMoney.newDesign.bankaccount.accountNumber")
        accountNameLbl.text = Localize("addMoney.newDesign.bankaccount.accountName")
        bankAddressLbl.text = Localize("addMoney.newDesign.bankaccount.bankAddress")
        purposeOfPaymentLbl.text = Localize("addMoney.newDesign.bankaccount.purpose")
        companyAddressLbl.text = Localize("addMoney.newDesign.bankaccount.companyAddress")
        
        emailButton.setTitle(Localize("addMoney.newDesign.bankaccount.emailMe"), for: UIControlState.normal)
        nextButton.setTitle(Localize("addMoney.newDesign.bankaccount.next"), for: UIControlState.normal)
        
        let swiftCredentials = self.swiftCredentials
        bicLabel.text = swiftCredentials?.bic
        accountNumberLabel.text = swiftCredentials?.accountNumber
        accountNameLabel.text = swiftCredentials?.accountName
        purposeOfPaymentLabel.text = swiftCredentials?.purposeOfPayment.replacingOccurrences(of: "{1}", with: "")
        purposeOfPaymentLabel.text = purposeOfPaymentLabel.text?.replacingOccurrences(of: "{0}", with: "")
        bankAddressLabel.text = swiftCredentials?.bankAddress
        companyAddressLabel.text = swiftCredentials?.companyAddress
        imageHeight.constant =  Display.height
        
        let authManager = LWAuthManager.instance()
//        authManager?.requestBaseAssets()
        authManager?.requestSwiftCredential("CHF")
    }

    
    @IBAction func nextAction(_ sender: UIButton) {
        
//        let parentVC = self.parent as! LWAddMoneyViewController
//        parentVC.nextAction(sender)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
