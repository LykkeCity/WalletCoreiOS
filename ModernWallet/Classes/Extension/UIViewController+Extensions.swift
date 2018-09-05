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
import SwiftSpinner

extension UIViewController {
    
    @IBAction func swipeToNavigateBack(_ sender: UISwipeGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    func showLoading() {
        if UIApplication.shared.keyWindow == nil {
            let container = UIApplication.shared.windows.first ?? self.view
            //set container view if keyWindow is nil so that SwiftSpinner can use it as superview
            SwiftSpinner.useContainerView(container)
        }
        
        SwiftSpinner.show("Loading...")
    }
    
    func hideLoading() {
        SwiftSpinner.hide()
    }
    
    func show(error dictionary: [AnyHashable : Any]) {
        
        let errorCode = dictionary[AnyHashable("Code")] as? Int ?? 0
        if (errorCode == 70) {
            showPendingDisclaimer()
        }
        else {
            let errorMessage = dictionary[AnyHashable("Message")] as? String ?? Localize("errors.server.problems")
            show(errorMessage: errorMessage)
        }
    }
    
    func showPendingDisclaimer() {
        DispatchQueue.main.async {
            guard let visibleVC = (UIApplication.shared.delegate as? AppDelegate)?.visibleViewController else {
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let disclaimerVC = storyboard.instantiateViewController(withIdentifier: "dimViewController")
            
            disclaimerVC.transitioningDelegate = DimPresentationManager.shared
            disclaimerVC.modalPresentationStyle = .custom
            
            visibleVC.present(disclaimerVC, animated: true)
        }
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
    
    /// Present login view controller in respect of DispatchQueue.async as showing/hiding loading indicator while presenting
    func presentLoginController() {
        let signInStory = UIStoryboard.init(name: "SignIn", bundle: nil)
        let signUpNav = signInStory.instantiateInitialViewController()!// instantiateViewController(withIdentifier: "SignUpNav")
        
        //show loading indicator to prevent blinking
        showLoading()
        DispatchQueue.main.async { [weak self] in
            self?.present(signUpNav, animated: false) {
                //hide indicator once the login view controller has been presented
                self?.hideLoading()
            }
        }
    }
    
}
