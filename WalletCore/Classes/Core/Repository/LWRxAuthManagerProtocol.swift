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
    associatedtype ResultType
    associatedtype RequestParams
    
    func request(withParams params: RequestParams) -> Observable<Result>
    func createPacket(withObserver observer: Any, params: RequestParams) -> Packet
    
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

public extension AuthManagerProtocol where Result == ApiResult<ResultType> {
    
    func defaultRequestImplementation(with params: RequestParams) -> Observable<Result> {
        
        return ReachabilityService.instance.reachabilityStatus
            .filter {$0}
            .flatMapLatest {_ in
                return Observable<Result>.create { observer in
                    let pack = self.createPacket(withObserver: observer, params: params)
                    GDXNet.instance().send(pack, userInfo: nil, method: .REST)
                    
                    return Disposables.create {}
                }
                .startWith(ApiResult.loading)
            }
            .observeOn(MainScheduler.instance)
            .shareReplay(1)
    }
    
    func request(withParams params: RequestParams) -> Observable<Result> {
        return defaultRequestImplementation(with: params)
    }
    
    func getErrorResult(fromPacket packet: Packet) -> Result {
        return ApiResult<ResultType>.error(withData: packet.errors)
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return ApiResult<ResultType>.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return ApiResult<ResultType>.notAuthorized
    }
}

public extension AuthManagerProtocol where Packet == ResultType, Result == ApiResult<ResultType> {
    
    func getSuccessResult(fromPacket packet: Packet) -> Result {
        return ApiResult<ResultType>.success(withData: packet)
    }
}

public extension AuthManagerProtocol where Result == ApiResult<ResultType>, RequestParams == Void {

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

