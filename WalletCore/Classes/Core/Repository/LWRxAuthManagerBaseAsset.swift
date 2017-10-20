//
//  LWRxAuthManagerBaseAsset.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerBaseAsset: LWRxAuthManagerBase<LWPacketBaseAssetGet> {
    
    public func requestBaseAssetGet() -> Observable<ApiResult<LWAssetModel>> {
        
        if let baseAssetId = LWCache.instance().baseAssetId, let baseAsset = LWCache.asset(byId: baseAssetId) {
            return Observable
                .just(ApiResult.success(withData: baseAsset))
                .startWith(ApiResult.loading)
        }
        
        return Observable.create{observer in
            let packet = LWPacketBaseAssetGet(observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketBaseAssetGet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWAssetModel>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketBaseAssetGet) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWAssetModel>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketBaseAssetGet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWAssetModel>> else {return}
        observer.onNext(.success(withData: packet.asset))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWAssetModel> {
    public func filterSuccess() -> Observable<LWAssetModel> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
