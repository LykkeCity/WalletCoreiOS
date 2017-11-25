//
//  EndBankViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/28/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import KYDrawerController
import WalletCore

class EndBankViewController: UIViewController {
    
    @IBOutlet weak var returnToPortfolioButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
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
