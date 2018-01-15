//
//  LWRxAuthManagerProtocol.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public protocol AuthManagerProtocol: NSObjectProtocol {
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
public protocol ApiResultProtocol {
    
}
extension ApiResult: ApiResultProtocol {}
extension ApiResultList: ApiResultProtocol {}

public extension AuthManagerProtocol where Result: ApiResultProtocol {
    
    func createPacket(withObserver observer: Any, params: RequestParams) -> Packet {
        fatalError("Provide implementation")
    }
    
    func defaultRequestImplementation(with params: RequestParams) -> Observable<Result> {
        return Observable<ApiResult<Any>>.create { observer in
                let pack = self.createPacket(withObserver: observer, params: params)
                GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
                return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1) as! Observable<Self.Result>
    }
    
    func request(withParams params: RequestParams) -> Observable<Result> {
        return defaultRequestImplementation(with: params)
    }
    
    func getErrorResult(fromPacket packet: Packet) -> Result {
        return ApiResult<Any>.error(withData: packet.errors) as! Self.Result
    }
    
    func getSuccessResult(fromPacket packet: Packet) -> Result {
        return ApiResult.success(withData: packet) as! Self.Result
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return ApiResult<Any>.forbidden as! Self.Result
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return ApiResult<Any>.notAuthorized as! Self.Result
    }
}

public extension AuthManagerProtocol where Result: ApiResultProtocol, RequestParams == Void {

    func request(withParams params: Void = ()) -> Observable<Result> {
        return defaultRequestImplementation(with: params)
    }
}


extension AuthManagerProtocol {
    
    public func subscribe(observer: NSObject, succcess: Selector, error: Selector) {
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
    
    public func unsubscribe(observer: NSObject) {
        NotificationCenter.default.removeObserver(observer)
    }
    
    public func getPacket(fromNotification notification: NSNotification) -> Packet? {
        guard
            let ctx = notification.userInfo?[kNotificationKeyGDXNetContext] as? GDXRESTContext,
            let packet = ctx.packet as? Packet
        else {
            return nil
        }
        
        return packet
    }
    
    public func onError(_ notification: NSNotification) {
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
    
    public func onSuccess(_ notification: NSNotification) {
        guard let packet = getPacket(fromNotification: notification) else {
            return
        }
        
        packet.isRejected ? onError(notification) : onSuccess(packet: packet)
    }
    
    public func onNotAuthorized(withPacket packet: Packet) {
        guard let observer = packet.observer as? AnyObserver<Result> else { return }
        observer.onNext(getNotAuthrorizedResult(fromPacket: packet))
        observer.onCompleted()
    }
    
    public func onError(pack: Packet) {
        guard let observer = pack.observer as? AnyObserver<Result> else { return }
        observer.onNext(getErrorResult(fromPacket: pack))
        observer.onCompleted()
    }
    
    public func onSuccess(packet: Packet) {
        guard let observer = packet.observer as? AnyObserver<Result> else { return }
        observer.onNext(getSuccessResult(fromPacket: packet))
        observer.onCompleted()
    }
    
    public func onForbidden(withPacket packet: Packet) {
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

