//
//  LWRxAuthManagerGraphPeriods.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

import RxSwift

public class LWRxAuthManagerGraphPeriods: LWRxAuthManagerBase<LWPacketGraphPeriods> {
    
    public func requestGraphPeriods() -> Observable<ApiResult<LWPacketGraphPeriods>> {
        return Observable.create{observer in
            let pack = LWPacketGraphPeriods(observer: observer)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketGraphPeriods) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketGraphPeriods>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketGraphPeriods) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketGraphPeriods>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketGraphPeriods) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketGraphPeriods>> else {return}
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketGraphPeriods> {
    public func filterSuccess() -> Observable<LWPacketGraphPeriods> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
