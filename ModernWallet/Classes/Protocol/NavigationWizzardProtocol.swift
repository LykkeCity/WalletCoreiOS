//
//  NavigationWizzardProtocol.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/26/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import WalletCore

protocol NavigationWizzardProtocol {
    var backButton: UIButton!{get}
    var pageIndicators: [UIButton]{get}
    var moneyLabel: UILabel!{get}
    
    func managePageIndicators(_ navigationController: UINavigationController, willShow viewController: UIViewController)
    func manageBackButtonVisibility(_ navigationController: UINavigationController, willShow viewController: UIViewController)
    func getMaxIndicatorCount(_ navigationController: UINavigationController, willShow viewController: UIViewController) -> Int
}

extension NavigationWizzardProtocol {
    func manageBackButtonVisibility(_ navigationController: UINavigationController, willShow viewController: UIViewController) {
        backButton.isHidden = navigationController.childViewControllers.count <= 1
    }
    
    func manageAddMoneyLabel(_ navigationController: UINavigationController, willShow viewController: UIViewController) {
        if navigationController.childViewControllers.count <= 1{
            moneyLabel.text = Localize("addMoney.newDesign.addMoneyFrom")
        }
            
        else {
            
            if var baseLabelString = Localize("addMoney.newDesign.addMoneyFrom") {
                baseLabelString = baseLabelString.appending(" ")
                if let startViewController = navigationController.childViewControllers.first as? StartViewController {
                    baseLabelString = baseLabelString.appending(startViewController.selectedPaymentMethod)
                    moneyLabel.text = baseLabelString
                }
            }
        }
    }
    
    func managePageIndicators(_ navigationController: UINavigationController, willShow viewController: UIViewController) {
        if navigationController.childViewControllers.count <= 1 {
            pageIndicators.forEach{$0.isHidden = true}
            return
        }
        
        let maxIndicatorsCount = getMaxIndicatorCount(navigationController, willShow: viewController)
        
        pageIndicators.enumerated().forEach{(index, button) in
            button.isHidden = index >= maxIndicatorsCount
        }
        
        pageIndicators.enumerated().forEach{(index, button) in
            button.isSelected = navigationController.childViewControllers.count - 2 == index
        }
    }
}
