//
//  RootViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 24.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class RootViewController: UIViewController {
    
    @IBOutlet private weak var chatButton: UIButton!
    @IBOutlet fileprivate weak var backButton: UIButton!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var titleBarHeightContraint: NSLayoutConstraint!
    private var embededNavigationController: UINavigationController!
    fileprivate var removePreviousViewControllers = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatButton.setTitle(Localize("newDesign.chatNow"), for: .normal)
        // Dev note: Updated for LMW-445 , please remove the following line when the feature is implemented
        chatButton.isHidden = true
    }

    func embed(viewController: UIViewController, animated: Bool) {
        if animated {
            removePreviousViewControllers = true
            embededNavigationController.pushViewController(viewController, animated: true)
        }
        else {
            embededNavigationController.setViewControllers([viewController], animated: false)
        }
    }

    // MARK: - IBActions
    
    @IBAction private func menuTapped() {
        drawerController?.setDrawerState(.opened, animated: true)
    }
    
    @IBAction private func chatTapped() {
        
    }
    
    @IBAction private func backTapped() {
        guard embededNavigationController.viewControllers.count > 1 else { return }
        embededNavigationController.popViewController(animated: true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedNavController" {
            guard let navController = segue.destination as? UINavigationController else { return }
            embededNavigationController = navController
            navController.delegate = self
        }
    }

}

extension RootViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        updateTitleBar(for: navigationController.viewControllers)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if removePreviousViewControllers {
            removePreviousViewControllers = false
            navigationController.setViewControllers([viewController], animated: false)
            updateTitleBar(for: [viewController])
        }
    }
    
    private func updateTitleBar(for viewControllers: [UIViewController]) {
        backButton.isHidden = viewControllers.count == 1 || removePreviousViewControllers
        let title: String? = viewControllers.flatMap { $0.navigationItem.title }.last
        titleLabel.text = title
        let shouldHideTitleBar = title == nil && backButton.isHidden
        titleBarHeightContraint.constant = shouldHideTitleBar ? 0.0 : 44.0
        UIView.animate(withDuration: 0.3) {
            self.titleLabel.superview?.layoutIfNeeded()
        }
    }
    
}
