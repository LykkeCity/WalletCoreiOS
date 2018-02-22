//
//  AppDelegate.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 10.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//
import Foundation
import UIKit
import CoreData
import AFNetworking
import WalletCore
import Toast
import PushKit
import RxSwift
import Firebase
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let userDefaults = UserDefaults.standard
    let disposeBag = DisposeBag()
    let offcainService = OffchainService.instance
    
    let blurViewTag = 10
    
    var inactivitySubscription: Disposable?
    let pinInactivityInterval = RxTimeInterval(10)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Configure tracker from GoogleService-Info.plist.
        
        WalletCoreConfig.configurePartnerId("LykkeModernMoney", testingServer: .test)
        
        AFNetworkReachabilityManager.shared().startMonitoring()
        subsctibeForNotAuthorized()
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            application.statusBarOrientation = .portrait
        }
        
        //Clear keychain on first run in case of reinstallation
//        let success: Bool = URLProtocol.registerClass(LWURLProtocol.self)
        
        if userDefaults.object(forKey: "FirstRun") == nil {
            // Delete values from keychain here
            LWKeychainManager.instance().clear()
            userDefaults.setValue("1strun", forKey: "FirstRun")
            userDefaults.synchronize()
        }
        
        LWLocalizationManager.shared().downloadLocalization()
        customizeNavigationBar()
        
        CSToastManager.setQueueEnabled(false)
        
        offcainService
            .finalizePendingRequests(refresh: FinalizePendingRequestsTrigger.instance.trigger(interval: 600),
                                     maxProcessingTime: 600)
            .subscribe()
            .disposed(by: disposeBag)
        
        LWAuthManager.instance().requestAPIVersion()
        
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        FirebaseApp.configure()
        
        ReachabilityService.instance
            .reachabilityStatus
            .filter{!$0}
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                let noConnectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnection")
                noConnectionViewController.modalTransitionStyle = .crossDissolve
                
                // Don't show the NoConnectionViewController if the PinViewController is about to be presented
                if !(self?.visibleViewController is NoConnectionViewController)
                    && !(self?.visibleViewController is PinViewController) {
                    self?.visibleViewController?.present(noConnectionViewController, animated: true)
                }
            })
            .disposed(by: disposeBag)

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {        
        // Show blur when app goes to background (also when the Task Switcher is opened)
        let blurredImageView = buildBlurredImageViewFromVisibleViewController()
        blurredImageView.tag = blurViewTag
        self.window?.addSubview(blurredImageView)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let app = UIApplication.shared
        var bgTask: UIBackgroundTaskIdentifier
        bgTask = app.beginBackgroundTask(expirationHandler: {() -> Void in
            //       [app endBackgroundTask:bgTask];
        })
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(ino64_t(30 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            self.waitForImage(toUpload: bgTask)
        })
        
        createInactivityTimer()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        invalidateInactivityTimer()

        // Dismiss the blur when app is active again
        if let coverView = self.window?.viewWithTag(blurViewTag) {
            coverView.removeFromSuperview()
        }
        
        Siren.shared.checkVersion(checkType: .immediately)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        // Dismiss the blur when app is active again
        if let coverView = self.window?.viewWithTag(blurViewTag) {
            coverView.removeFromSuperview()
        }
        
        Siren.shared.checkVersion(checkType: .daily)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
//        self.saveContext()
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard LWKeychainManager.instance().isAuthenticated else {
            completionHandler(.noData)
            return
        }
        
        offcainService
            .finalizePendingRequests(refresh: Observable.just(Void()), maxProcessingTime: 20)
            .subscribe(onNext: { pendingRequests in
                
                guard pendingRequests.succeeded.isEmpty else {
                    completionHandler(.newData)
                    return
                }
                
                guard pendingRequests.failed == 0 else {
                    completionHandler(.failed)
                    return
                }
                
                completionHandler(.noData)
            })
            .disposed(by: disposeBag)
    }
}
