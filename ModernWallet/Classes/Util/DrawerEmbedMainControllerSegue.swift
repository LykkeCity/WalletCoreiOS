//
//  DrawerEmbedMainControllerSegue.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 6.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

class DrawerEmbedMainControllerSegue: UIStoryboardSegue {
    
    final override func perform() {
        guard
            let drawerController = source.drawerController,
            let rootViewController = drawerController.mainViewController as? RootViewController
        else { return }
        rootViewController.embed(viewController: destination, animated: true)
        drawerController.setDrawerState(.closed, animated: false)
//        drawerController.endAppearanceTransition()
        
//        let navViewController = destination.childViewControllers.first{ $0 is UINavigationController}
//        let portfolioViewController = navViewController?.childViewControllers.first{ $0 is PortfolioViewController }
//        portfolioViewController?.viewDidAppear(true)
    }

}
