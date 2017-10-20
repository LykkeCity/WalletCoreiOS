//
//  BuyStep4ViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 7/25/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class BuyStep4ViewController: UIViewController {
    
    @IBOutlet weak var buyWithCurrencyLbl: UILabel!
    @IBOutlet weak var unitsValue: UILabel!
    @IBOutlet weak var unitsTitle: UILabel!
    @IBOutlet weak var unitsCurrency: UILabel!
    @IBOutlet weak var unitsAmount : UILabel!
    @IBOutlet weak var priceCurrency: UILabel!
    @IBOutlet weak var totalCurrency: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var buyWithValue: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var priceValue: UILabel!
    @IBOutlet weak var priceAmount: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    var dict: [String:String]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        
        imageHeight.constant =  Display.height
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dict != nil {
            self.unitsAmount.text = dict?["UnitsAmount"]
            self.unitsValue.text = dict?["UnitsValue"]
            unitsCurrency.text = dict?["UnitsCurrency"]
            priceValue.text = dict?["PriceValue"]
            priceAmount.text = dict?["PriceAmount"]
            priceCurrency.text = dict?["PriceCurrency"]
            totalCurrency.text = dict?["TotalCurrency"]
            totalValue.text = dict?["TotalValue"]
            totalAmount.text = dict?["TotalAmount"]
            buyWithCurrencyLbl.text = dict?["BuyWithCurrency"]
            buyWithValue.text = dict?["BuywithValue"]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func portfolioAction(_ sender: UIButton) {
        if let parentVC = self.navigationController?.parent as? BuyViewController {
                parentVC.onBackTap(sender)
        }
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
