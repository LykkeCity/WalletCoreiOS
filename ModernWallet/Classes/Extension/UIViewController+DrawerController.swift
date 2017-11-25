//
//  UIViewController+DrawerController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 6.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

extension UIViewController {

    var drawerController: DrawerController? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if let drawerController = viewController as? DrawerController {
                return drawerController
            }
            viewController = viewController?.parent
        }
        return nil
    }
    
}
