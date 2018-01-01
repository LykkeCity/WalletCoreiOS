//
//  UIWIndow+Extensions.swift
//  ModernMoney
//
//  Created by Lyubomir Marinov on 21.12.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift

extension UIWindow {
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let delegate = UIApplication.shared.delegate as? AppDelegate, delegate.window?.isKeyWindow ?? false {
            delegate.invalidateInactivityTimer()
        }
        
        return true
    }
}
