//
//  LWRxAuthManagerBaseAsset.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public protocol LWRxAuthManagerBaseAssetProtocol {
    func request() -> Observable<ApiResult<LWAssetModel>>
}

public class LWRxAuthManagerBaseAsset: NSObject, LWRxAuthManagerBaseAssetProtocol  {
    
    public typealias Packet = LWPacketBaseAssetGet
    public typealias Result = ApiResult<LWAssetModel>
    public typealias ResultType = LWAssetModel
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

extension LWRxAuthManagerBaseAsset: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketBaseAssetGet {
        return Packet(observer: observer)
    }
    
    public func request() -> Observable<Result> {
        return self.request(withParams: ())
    }
    
    public func request(withParams params: RequestParams) -> Observable<Result> {
        if let baseAssetId = LWCache.instance().baseAssetId, let baseAsset = LWCache.asset(byId: baseAssetId) {
            return Observable
                .just(ApiResult.success(withData: baseAsset))
                .startWith(ApiResult.loading)
        }
        
        return self.defaultRequestImplementation(with: ())
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.asset)
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
