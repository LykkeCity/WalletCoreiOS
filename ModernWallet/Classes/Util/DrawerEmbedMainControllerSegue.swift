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
        guard let drawerController = source.drawerController else { return }
        drawerController.mainViewController = destination
    }

}
