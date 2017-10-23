//
//  CashOutViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 10.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class CashOutViewController: UIViewController {
    
    @IBOutlet fileprivate var backButton: UIButton!

    @IBOutlet private var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.isHidden = true
        
        titleLabel.text = Localize("cashOut.newDesign.title")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "EmbedNavController", let navController = segue.destination as? UINavigationController else {
            return
        }
        navController.delegate = self
        cashOutNavigationController = navController
    }
    
    // MARK: - Private
    
    private var cashOutNavigationController: UINavigationController!
    
    @IBAction private func backPressed() {
        cashOutNavigationController.popViewController(animated: true)
    }

}

extension CashOutViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        backButton.isHidden = navigationController.viewControllers.count < 2
    }
    
}
