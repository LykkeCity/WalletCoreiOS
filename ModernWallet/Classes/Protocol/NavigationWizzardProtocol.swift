//
//  NavigationWizzardProtocol.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/26/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

protocol NavigationWizzardProtocol {
    var backButton: UIButton!{get}
    var pageIndicators: [UIButton]{get}
    
    func managePageIndicators(_ navigationController: UINavigationController, willShow viewController: UIViewController)
    func manageBackButtonVisibility(_ navigationController: UINavigationController, willShow viewController: UIViewController)
    func getMaxIndicatorCount(_ navigationController: UINavigationController, willShow viewController: UIViewController) -> Int
}

extension NavigationWizzardProtocol {
    func manageBackButtonVisibility(_ navigationController: UINavigationController, willShow viewController: UIViewController) {
        backButton.isHidden = navigationController.childViewControllers.count <= 1
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
