//
//  LWNetworkClient+Extension.swift
//  ModernMoney
//
//  Created by Nacho Nachev  on 20.12.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import WalletCore

extension LWNetworkTemplate: LWAuthManagerDelegate {
    
    func showReleaseError(_ error: NSError, request: NSURLRequest) {
        guard request.showErrorIfFailed else {
            return
        }
        DispatchQueue.main.async {
            guard let viewController = (UIApplication.shared.delegate as? AppDelegate)?.visibleViewController else {
                return
            }
            if error.code == NSURLErrorUserCancelledAuthentication {
                MenuTableViewController.logout(viewController)
                return
            }
            var message = error.userInfo["Message"] as? String
            if message == nil {
                message = error.localizedDescription
            }
            if message == nil {
                message = "Unknown server error"
            }
            viewController.show(errorMessage: message)
        }
    }
    
    func showBackupView(_ isOptional: Bool, message: String) {
        DispatchQueue.main.async {
            guard let visibleVC = (UIApplication.shared.delegate as? AppDelegate)?.visibleViewController else {
                return
            }
            
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let backupVC = storyboard.instantiateViewController(withIdentifier: "BackupPrivateKey")
            visibleVC.present(backupVC, animated: true)
        }
    }
    
    func showPendingDisclaimer() {
        DispatchQueue.main.async {
            guard let visibleVC = (UIApplication.shared.delegate as? AppDelegate)?.visibleViewController else {
                return
            }
            
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let backupVC = storyboard.instantiateViewController(withIdentifier: "BackupPrivateKey")
            visibleVC.present(backupVC, animated: true)
        }
    }
    
    func showKycView() {
        guard
            let visibleVC = (UIApplication.shared.delegate as? AppDelegate)?.visibleViewController,
            let authManager = LWAuthManager.instance()
        else {
            return
        }
        visibleVC.rx.loading.onNext(true)
        authManager.delegate = self
        authManager.requestKYCStatusGet()
    }
    
    public func authManager(_ manager: LWAuthManager!, didGetKYCStatus status: String!, personalData: LWPersonalDataModel!) {
        guard let visibleVC = (UIApplication.shared.delegate as? AppDelegate)?.visibleViewController else {
            return
        }
        visibleVC.rx.loading.onNext(false)
        let identifier: String
        switch status {
        case "Pending", "Rejected":
            identifier = "kycPendingVC"
        case "NeedToFillData":
            identifier = "kycTabNVC"
        case "RestrictedArea":
            fallthrough
        default:
            return
        }
        let kycVC = UIStoryboard(name: "KYC", bundle: nil).instantiateViewController(withIdentifier: identifier)
        visibleVC.present(kycVC, animated: true)
    }
}
