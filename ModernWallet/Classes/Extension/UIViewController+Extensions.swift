//
//  UIViewController+Extensions.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/27/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import UIKit
import WalletCore
import RxSwift
import RxCocoa

extension UIViewController {
    
    @IBAction func swipeToNavigateBack(_ sender: UISwipeGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    func show(error dictionary: [AnyHashable : Any]) {
        let errorMessage = dictionary[AnyHashable("Message")] as? String ?? Localize("errors.server.problems")
        show(errorMessage: errorMessage)
    }
        
    func show(errorMessage: String?) {
        let alertController = UIAlertController(title: Localize("utils.error"), message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }

}
