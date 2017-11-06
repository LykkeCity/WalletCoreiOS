//
//  LWRxAuthManagerProtocol.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

protocol AuthManagerProtocol: NSObjectProtocol {
    associatedtype Packet: LWPacket
    associatedtype Result
    associatedtype RequestParams
    
    func request(withParams params: RequestParams) -> Observable<Result>
    
    func subscribe(observer: NSObject, succcess: Selector, error: Selector)
    func unsubscribe(observer: NSObject)
    func getPacket(fromNotification notification: NSNotification) -> Packet?
    
    func onError(_ notification: NSNotification)
    func onError(pack: Packet)
    
    func onSuccess(_ notification: NSNotification)
    func onSuccess(packet: Packet)
    
    func onNotAuthorized(withPacket packet: Packet)
    func onForbidden(withPacket packet: Packet)
 
    func getErrorResult(fromPacket packet: Packet) -> Result
    func getSuccessResult(fromPacket packet: Packet) -> Result
    func getForbiddenResult(fromPacket packet: Packet) -> Result
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result
}

extension AuthManagerProtocol {
    func subscribe(observer: NSObject, succcess: Selector, error: Selector) {
        NotificationCenter.default.addObserver(
            observer,
            selector: succcess,
            name: NSNotification.Name(rawValue: kNotificationGDXNetAdapterDidReceiveResponse),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            observer,
            selector: error,
            name: NSNotification.Name(rawValue: kNotificationGDXNetAdapterDidFailRequest),
            object: nil
        )
    }
    
    func unsubscribe(observer: NSObject) {
        NotificationCenter.default.removeObserver(observer)
    }
    
    func getPacket(fromNotification notification: NSNotification) -> Packet? {
        guard
            let ctx = notification.userInfo?[kNotificationKeyGDXNetContext] as? GDXRESTContext,
            let packet = ctx.packet as? Packet
        else {
            return nil
        }
        
        return packet
    }
    
    func onError(_ notification: NSNotification) {
        guard let ctx = notification.userInfo?[kNotificationKeyGDXNetContext] as? GDXRESTContext else { return }
        guard let pack = getPacket(fromNotification: notification) else { return }
        
        if LWAuthManager.isAuthneticationFailed(ctx.task?.response) {
            onNotAuthorized(withPacket: pack)
            return
        }
        
        if LWAuthManager.isForbidden(ctx.task?.response) {
            onForbidden(withPacket: pack)
            return
        }
        
        onError(pack: pack)
    }
    
    func onSuccess(_ notification: NSNotification) {
        guard let packet = getPacket(fromNotification: notification) else {
            return
        }
        
        packet.isRejected ? onError(notification) : onSuccess(packet: packet)
    }
    
    func onNotAuthorized(withPacket packet: Packet) {
        guard let observer = packet.observer as? AnyObserver<Result> else { return }
        observer.onNext(getNotAuthrorizedResult(fromPacket: packet))
        observer.onCompleted()
    }
    
    func onError(pack: Packet) {
        guard let observer = pack.observer as? AnyObserver<Result> else { return }
        observer.onNext(getErrorResult(fromPacket: pack))
        observer.onCompleted()
    }
    
    func onSuccess(packet: Packet) {
        guard let observer = packet.observer as? AnyObserver<Result> else { return }
        observer.onNext(getSuccessResult(fromPacket: packet))
        observer.onCompleted()
    }
    
    func onForbidden(withPacket packet: Packet) {
        guard let observer = packet.observer as? AnyObserver<Result> else { return }
        observer.onNext(getForbiddenResult(fromPacket: packet))
        observer.onCompleted()
    }
}

extension LWPacket {
    var errors: [AnyHashable : Any] {
        return reject as? [AnyHashable : Any] ?? [:]
    }
}

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

