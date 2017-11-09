//
//  DrawerController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import KYDrawerController

class DrawerController: KYDrawerController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.showPortfolio), name: .loggedIn, object: nil)
        
        if((UserDefaults.standard.value(forKey: "loggedIn")) == nil) {
            presentLoginController()
        }
        
        // Do any additional setup after loading the view.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func showPortfolio() {
        mainViewController = storyboard?.instantiateViewController(withIdentifier: "Portfolio")
        self.setDrawerState(.closed, animated: false)
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
