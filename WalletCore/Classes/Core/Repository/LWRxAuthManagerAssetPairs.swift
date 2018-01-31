//
//  LWRxAuthManagerAssetPairs.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
public protocol LWRxAuthManagerAssetPairsProtocol {
    func request(baseAsset: LWAssetModel, quotingAsset: LWAssetModel) -> Observable<ApiResult<LWAssetPairModel?>>
    func request(byId id: String) -> Observable<ApiResult<LWAssetPairModel?>>
    func request() -> Observable<ApiResult<[LWAssetPairModel]>>
}

public class LWRxAuthManagerAssetPairs: NSObject,LWRxAuthManagerAssetPairsProtocol{
    
    public typealias Packet = LWPacketAssetPairs
    public typealias Result = ApiResult<[LWAssetPairModel]>
    public typealias ResultType = [LWAssetPairModel]
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
    
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketAssetPairs {
        return Packet(observer: observer)
    }
    
    public func request() -> Observable<Result> {
        return self.request(withParams: ())
    }
    
    public func request(baseAsset: LWAssetModel, quotingAsset: LWAssetModel) -> Observable<ApiResult<LWAssetPairModel?>> {
        return request(withParams: ())
            .filterSuccess()
            .map{ pairs in
                pairs.first { (model: LWAssetPairModel) in
                    (model.baseAssetId == baseAsset.identity && model.quotingAssetId == quotingAsset.identity) ||
                    (model.baseAssetId == quotingAsset.identity && model.quotingAssetId == baseAsset.identity)
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

public extension ObservableType where Self.E == ApiResult<[LWAssetPairModel]> {
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
