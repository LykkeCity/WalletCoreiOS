//
//  BuyPinViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/13/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

class BuyPinViewController: UIViewController {

    var delegate: PinViewControllerDelegate? {
        get {
            return (self.childViewControllers.first as? PinViewController)?.delegate
        }
        
        set {
            (self.childViewControllers.first as? PinViewController)?.delegate = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelDidTap(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
