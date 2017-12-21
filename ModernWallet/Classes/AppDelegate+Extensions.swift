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
    
    func subsctibeForNotAuthorized() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.processRequestFailure(_:)),
            name: NSNotification.Name(rawValue: kNotificationGDXNetAdapterDidFailRequest),
            object: nil
        )
    }
    
    func processRequestFailure(_ notification: NSNotification) {
        guard let ctx = notification.userInfo?[kNotificationKeyGDXNetContext] as? GDXRESTContext else { return }

        let visibleViewController = self.visibleViewController

        if LWAuthManager.isAuthneticationFailed(ctx.task?.response) {
            guard !(visibleViewController is SignUpFormViewController) else { return }
            let loginViewController = UIStoryboard(name: "SignIn", bundle: nil).instantiateInitialViewController()!
            visibleViewController?.present(loginViewController, animated: true)
        }
        else {
            guard
                let error = ctx.error as NSError?,
                error.domain == NSURLErrorDomain,
                error.code == NSURLErrorNotConnectedToInternet,
                !(visibleViewController is NoConnectionViewController)
            else {
                return
            }
            let noConnectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnection")
            noConnectionViewController.modalTransitionStyle = .crossDissolve
            visibleViewController?.present(noConnectionViewController, animated: true)
        }
    }
    
    var visibleViewController: UIViewController? {
        
        guard let rootViewController = window?.rootViewController else {
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
    
    func waitForImage(toUpload taskId: UIBackgroundTaskIdentifier) {
        guard LWKYCDocumentsModel.shared().isUploadingImage() else {
            UIApplication.shared.endBackgroundTask(taskId)
            return
        }
        
        let deadline = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: deadline) {[weak self] in
            self?.waitForImage(toUpload: taskId)
        }
    }
    
    func customizeNavigationBar() {
        UINavigationBar.appearance().barTintColor = UIColor(hexString: kNavigationTintColor)
        UINavigationBar.appearance().tintColor = UIColor(hexString: kNavigationBarTintColor)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }
    
    func buildBlurredImageViewFromVisibleViewController() -> UIImageView {
        let screenBounds = UIScreen.main.bounds
        let blurredImageView = UIImageView(frame: screenBounds)
        
        let backgroundImageName = "Background"
        blurredImageView.image = UIImage(named: backgroundImageName, in: Bundle(for: BackgroundView.self), compatibleWith: nil)
        
        blurredImageView.contentMode = .scaleAspectFill

        guard let visibleViewController = self.visibleViewController else {
            return blurredImageView
        }
        
        let blurRadius: CGFloat = 20.0
        let tintColor = UIColor.clear
        let saturationDeltaFactor: CGFloat = 2.0
        
        UIGraphicsBeginImageContext(screenBounds.size)
        visibleViewController.view.drawHierarchy(in: screenBounds, afterScreenUpdates: true)
        guard let snapshotImage = UIGraphicsGetImageFromCurrentImageContext(),
            let blurredSnapshotImage = UIImageEffects.imageByApplyingBlur(to: snapshotImage,
                                                                      withRadius: blurRadius,
                                                                      tintColor: tintColor,
                                                                      saturationDeltaFactor: saturationDeltaFactor,
                                                                      maskImage: nil) else {
                                                                        return blurredImageView
        }
        blurredImageView.image = blurredSnapshotImage
        
        return blurredImageView
    }
}
