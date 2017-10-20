//
//  TopNavViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/19/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import KYDrawerController
import WalletCore

class TopNavViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func menuAction(_ sender:UIButton) {

        if let drawerController = self.parent?.parent as? KYDrawerController {
             drawerController.setDrawerState(.opened, animated: true)
        }
    }

}
