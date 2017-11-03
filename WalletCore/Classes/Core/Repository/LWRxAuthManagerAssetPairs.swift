//
//  LWRxAuthManagerAssetPairs.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerAssetPairs: LWRxAuthManagerBase<LWPacketAssetPairs> {
    
    public func requestAssetPairs() -> Observable<ApiResultList<LWAssetPairModel>> {

// TODO: fix that, for some reason no asset pairs are shown on buy step 1, when called twice
//        if let cachedAssetPairs = LWCache.instance().allAssetPairs?.map({$0 as! LWAssetPairModel}), cachedAssetPairs.isNotEmpty  {
//            return Observable<ApiResultList<LWAssetPairModel>>
//                .just(.success(withData: cachedAssetPairs))
//                .startWith(.loading)
//        }
        
        return Observable.create{observer in
            let packet = LWPacketAssetPairs(observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    public func requestAssetPair(baseAsset: LWAssetModel, quotingAsset: LWAssetModel) -> Observable<ApiResult<LWAssetPairModel?>> {
        let pairId = baseAsset.getPairId(withAsset: quotingAsset)
        let reversedPairId = quotingAsset.getPairId(withAsset: baseAsset)
        
        return requestAssetPairs()
            .filterSuccess()
            .map{ pairs in
                pairs.first{ model in
                    model.identity == pairId || model.identity == reversedPairId
                }
            }
            .map{ ApiResult.success(withData: $0) }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    public func requestAssetPair(byId id: String) -> Observable<ApiResult<LWAssetPairModel?>> {
        return requestAssetPairs().map{ result -> ApiResult<LWAssetPairModel?> in
            switch result {
                case .error(let data): return .error(withData: data)
                case .loading: return .loading
                case .notAuthorized: return .notAuthorized
                case .forbidden: return .forbidden
                case .success(let data): return .success(withData: data.first{pairModel in
                    return pairModel.identity == id
                })
            }
        }
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketAssetPairs) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWAssetPairModel>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketAssetPairs) {
        guard let observer = pack.observer as? AnyObserver<ApiResultList<LWAssetPairModel>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketAssetPairs) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWAssetPairModel>> else {return}
        
        guard let rates = packet.assetPairs else {
            observer.onNext(.success(withData: []))
            observer.onCompleted()
            return
        }
        
        observer.onNext(.success(withData: rates.map{$0 as! LWAssetPairModel}))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResultList<LWAssetPairModel> {
    public func filterSuccess() -> Observable<[LWAssetPairModel]> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}


public extension ObservableType where Self.E == ApiResult<LWAssetPairModel?> {
    public func filterSuccess() -> Observable<LWAssetPairModel?> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
