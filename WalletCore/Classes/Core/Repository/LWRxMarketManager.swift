//
//  LWRxMarketManager.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 8/3/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxMarketManager: LWRxAuthManagerBase<LWPacketMarket> {
    
    public func requestMarketPairs() -> Observable<ApiResultList<LWMarketModel>> {
        return Observable.create{observer in
            let pack = LWPacketMarket(observer: observer)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketMarket) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWMarketModel>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketMarket) {
        guard let observer = pack.observer as? AnyObserver<ApiResultList<LWMarketModel>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketMarket) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWMarketModel>> else {return}
        
        observer.onNext(.success(withData: packet.marketAssetPairs.map{$0 as! LWMarketModel}))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResultList<LWMarketModel> {
    public func filterSuccess() -> Observable<[LWMarketModel]> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
