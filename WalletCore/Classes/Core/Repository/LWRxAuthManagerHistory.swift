//
//  LWRxAuthManagerHistory.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/11/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerHistory: LWRxAuthManagerBase<LWPacketGetHistory> {
    
    public func requestGetHistory(forAssetId assetId: String? = nil) -> Observable<ApiResultList<LWBaseHistoryItemType>> {
        return Observable.create{observer in
            let pack = LWPacketGetHistory(observer: observer, assetId: assetId)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketGetHistory) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWBaseHistoryItemType>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketGetHistory) {
        guard let observer = pack.observer as? AnyObserver<ApiResultList<LWBaseHistoryItemType>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketGetHistory) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWBaseHistoryItemType>> else {return}
        let data: [LWBaseHistoryItemType] = LWHistoryManager
            .prepareHistory(packet.historyArray, marginal: [])
            .flatMap{$0 as? [LWBaseHistoryItemType] ?? []}
        
        observer.onNext(.success(withData: data))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResultList<LWBaseHistoryItemType> {
    public func filterSuccess() -> Observable<[LWBaseHistoryItemType]> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketGetHistory {
    convenience init(observer: Any, assetId: String?) {
        self.init()
        
        self.assetId = assetId
        self.observer = observer
    }
}
