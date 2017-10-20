//
//  LWRxAuthManagerProtocol.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerBase<T: LWPacket>: NSObject {
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onSuccess(_:)),
            name: NSNotification.Name(rawValue: kNotificationGDXNetAdapterDidReceiveResponse),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onError(_:)),
            name: NSNotification.Name(rawValue: kNotificationGDXNetAdapterDidFailRequest),
            object: nil
        )
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    private func getPacket(fromNotification notification: NSNotification) -> T? {
        guard let ctx = notification.userInfo?[kNotificationKeyGDXNetContext] as? GDXRESTContext,
            let packet = ctx.packet as? T
            else {
                return nil
        }
        
        return packet
    }
    
    @objc private func onSuccess(_ notification: NSNotification) {
        guard let packet = getPacket(fromNotification: notification) else {
            return
        }
        
        packet.isRejected ? onError(notification) : onSuccess(packet: packet)
    }
    
    func onSuccess(packet: T) {}
    
    @objc private func onError(_ notification: NSNotification) {
        guard let ctx = notification.userInfo?[kNotificationKeyGDXNetContext] as? GDXRESTContext else {return}
        guard let pack = getPacket(fromNotification: notification) else {return}
        
        
//         check if user not authorized - kick them
        if LWAuthManager.isAuthneticationFailed(ctx.task?.response) {
            onNotAuthorized(withPacket: pack)
            return
        }
        
        if LWAuthManager.isForbidden(ctx.task?.response) {
            onForbidden(withPacket: pack)
            return
        }
        
        let rejectData = pack.reject as? [AnyHashable : Any] ?? [:]
        onError(withData: rejectData, pack: pack)
    }
    
    func onNotAuthorized(withPacket packet: T) {
        
    }
    
    func onError(withData data: [AnyHashable : Any], pack: T) {
        
    }
    
    func onForbidden(withPacket packet: T) {
        
    }
}
