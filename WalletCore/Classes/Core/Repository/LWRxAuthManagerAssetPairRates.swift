//
//  LWRxAuthManagerAssetPairRates.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerAssetPairRates: LWRxAuthManagerBase<LWPacketAssetPairRates> {
    
    public func requestAssetPairRates(ignoreBase: Bool = false) -> Observable<ApiResultList<LWAssetPairRateModel>> {
        return Observable.create{observer in
            let packet = LWPacketAssetPairRates(observer: observer, ignoreBase: ignoreBase)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketAssetPairRates) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWAssetPairRateModel>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketAssetPairRates) {
        guard let observer = pack.observer as? AnyObserver<ApiResultList<LWAssetPairRateModel>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketAssetPairRates) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWAssetPairRateModel>> else {return}
        
        guard let rates = packet.assetPairRates else {
            observer.onNext(.success(withData: []))
            observer.onCompleted()
            return
        }
        
        observer.onNext(.success(withData: rates.map{$0 as! LWAssetPairRateModel}))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResultList<LWAssetPairRateModel> {
    public func filterSuccess() -> Observable<[LWAssetPairRateModel]> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}


extension LWPacketAssetPairRates {
    convenience init(observer: Any, ignoreBase: Bool) {
        self.init()
        self.observer = observer
        self.ignoreBaseAsset = ignoreBase
    }
}
