//
//  AppDelegate+Extensions.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 25.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//
import WalletCore
import RxSwift
import RxCocoa
import KYDrawerController

extension AppDelegate {
    func subscribeForPendingOffchainRequests() {
        OffchainService.instance.finalizePendingRequests(refresh: Observable<Void>.interval(120.0))
    }
    
    func subsctibeForNotAuthorized() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.showLoginScreenOnUnauthorized(_:)),
            name: NSNotification.Name(rawValue: kNotificationGDXNetAdapterDidFailRequest),
            object: nil
        )
    }
    
    func showLoginScreenOnUnauthorized(_ notification: NSNotification) {
        guard let ctx = notification.userInfo?[kNotificationKeyGDXNetContext] as? GDXRESTContext else { return }
        guard LWAuthManager.isAuthneticationFailed(ctx.task?.response)  else { return }
        
        let visibleViewController = self.visibleViewController
        let loginViewController = UIStoryboard(name: "SignIn", bundle: nil).instantiateViewController(withIdentifier: "SignUpNav")
        
        if visibleViewController is SignUpEmailViewController {
            return
        }
        
        visibleViewController?.present(loginViewController, animated: true)
    }
    
    var visibleViewController: UIViewController? {
        
        guard let rootViewController = window.rootViewController else {
            return nil
        }
        
        return getVisibleViewController(rootViewController)
    }
    
    private func getVisibleViewController(_ rootViewController: UIViewController) -> UIViewController? {
        
        if let presentedViewController = rootViewController.presentedViewController {
            return getVisibleViewController(presentedViewController)
        }
        
        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.visibleViewController
        }
        
        if let tabBarController = rootViewController as? UITabBarController {
            return tabBarController.selectedViewController
        }
        
        if let kyDrawerController = rootViewController as? KYDrawerController {
            return kyDrawerController.mainViewController
        }
        
        return rootViewController
    }
}
