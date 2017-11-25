//
//  AddMoneyCCStep3ViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/30/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class AddMoneyCCStep3ViewController: UIViewController {

    @IBOutlet weak var paymentCompleteLabel: UILabel!
    @IBOutlet weak var orderDetailsLabel: UILabel!
    @IBOutlet weak var orderRefLabel: UILabel!
    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var cardHolderNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var returnToPortfolioButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        
        paymentCompleteLabel.text = Localize("addMoney.newDesign.creditcard.paymentComplete")
        orderDetailsLabel.text = Localize("addMoney.newDesign.creditcard.orderDetails")
        orderRefLabel.text = Localize("addMoney.newDesign.creditcard.orderRef")
        orderDateLabel.text = Localize("addMoney.newDesign.creditcard.orderDate")
        amountLabel.text = Localize("addMoney.newDesign.creditcard.amount")
        paymentMethodLabel.text = Localize("addMoney.newDesign.creditcard.paymentMethod")
        cardHolderNameLabel.text = Localize("addMoney.newDesign.creditcard.cardHolderName")
        addressLabel.text = Localize("addMoney.newDesign.creditcard.address")
        countryLabel.text = Localize("addMoney.newDesign.creditcard.country")
        zipLabel.text = Localize("addMoney.newDesign.creditcard.zipPayment")
    returnToPortfolioButton.setTitle(Localize("addMoney.newDesign.bankaccount.returnToPortfolio"), for: UIControlState.normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func portfolioAction(_ sender: UIButton) {
//        let parentVC = self.parent as! LWAddMoneyViewController
//        parentVC.portfolioAction(sender)
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
