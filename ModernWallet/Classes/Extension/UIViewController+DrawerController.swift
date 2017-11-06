//
//  UIViewController+DrawerController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 6.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import KYDrawerController

extension UIViewController {

    var drawerController: KYDrawerController? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if let drawerController = viewController as? KYDrawerController {
                return drawerController
            }
            viewController = viewController?.parent
        }
        return nil
    }
    
}
