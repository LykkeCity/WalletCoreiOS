//
//  LWRxAuthManagerAssetPairRate.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerAssetPairRate: LWRxAuthManagerBase<LWPacketAssetPairRate> {
    
    public func requestAssetPairRate(pairId: String) -> Observable<ApiResult<LWAssetPairRateModel>> {
        return Observable.create{observer in
            let packet = LWPacketAssetPairRate(observer: observer, pairId: pairId)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketAssetPairRate) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWAssetPairRateModel>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketAssetPairRate) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWAssetPairRateModel>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketAssetPairRate) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWAssetPairRateModel>> else {return}
        if let assetPairRate = packet.assetPairRate {
            observer.onNext(.success(withData: assetPairRate))
        }
        
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWAssetPairRateModel> {
    public func filterSuccess() -> Observable<LWAssetPairRateModel> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}


extension LWPacketAssetPairRate {
    convenience init(observer: Any, pairId: String) {
        self.init()
        self.observer = observer
        self.identity = pairId
    }
}
