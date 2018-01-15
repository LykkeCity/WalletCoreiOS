//
//  LWRxAuthManagerAssetPairs.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerAssetPairs: NSObject{
    
    public typealias Packet = LWPacketAssetPairs
    public typealias Result = ApiResultList<LWAssetPairModel>
    public typealias ResultType = LWAssetPairModel
    public typealias RequestParams = Void
    
    override init() {
        super.init()
        subscribe(observer: self, succcess: #selector(self.successSelector(_:)), error: #selector(self.errorSelector(_:)))
    }
    
    deinit {
        unsubscribe(observer: self)
    }
    
    @objc func successSelector(_ notification: NSNotification) {
        onSuccess(notification)
    }
    
    @objc func errorSelector(_ notification: NSNotification) {
        onError(notification)
    }
}

extension LWRxAuthManagerAssetPairs: AuthManagerProtocol {
    
    public func request(withParams params: RequestParams = Void()) -> Observable<Result> {

// TODO: fix that, for some reason no asset pairs are shown on buy step 1, when called twice
//        if let cachedAssetPairs = LWCache.instance().allAssetPairs?.map({$0 as! LWAssetPairModel}), cachedAssetPairs.isNotEmpty  {
//            return Observable<ApiResultList<LWAssetPairModel>>
//                .just(.success(withData: cachedAssetPairs))
//                .startWith(.loading)
//        }
        
        return Observable.create{observer in
            let packet = Packet(observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    public func request(baseAsset: LWAssetModel, quotingAsset: LWAssetModel) -> Observable<ApiResult<LWAssetPairModel?>> {
        let pairId = baseAsset.getPairId(withAsset: quotingAsset)
        let reversedPairId = quotingAsset.getPairId(withAsset: baseAsset)
        
        return request(withParams: ())
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
    
    public func request(byId id: String) -> Observable<ApiResult<LWAssetPairModel?>> {
        return request(withParams: ()).map{ result -> ApiResult<LWAssetPairModel?> in
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
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        guard let rates = packet.assetPairs else {
            return Result.success(withData: [])
        }
        return Result.success(withData: rates.map{$0 as! LWAssetPairModel})
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
