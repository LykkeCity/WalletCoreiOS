//
//  SettingsViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 14.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class SettingsViewController: UIViewController {
    
    @IBOutlet fileprivate var backButton: UIButton!
    
    @IBOutlet fileprivate var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.isHidden = true
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

extension SettingsViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        backButton.isHidden = navigationController.viewControllers.count < 2
        titleLabel.text = viewController.navigationItem.title
    }
    
}

