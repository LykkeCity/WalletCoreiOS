//
//  LWRxAuthManagerAssetPairRates.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public protocol LWRxAuthManagerAssetPairRatesProtocol {
    func request() -> Observable<ApiResult<[LWAssetPairRateModel]>>
    
    /// <#Description#>
    ///
    /// - Parameter params: Ignore base asset
    /// - Returns: <#return value description#>
    func request(withParams params: Bool) -> Observable<ApiResult<[LWAssetPairRateModel]>>
}

public class LWRxAuthManagerAssetPairRates: NSObject, LWRxAuthManagerAssetPairRatesProtocol  {
    
    public typealias Packet = LWPacketAssetPairRates
    public typealias Result = ApiResult<[LWAssetPairRateModel]>
    public typealias ResultType = [LWAssetPairRateModel]
    public typealias RequestParams = (Bool)
    
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

extension LWRxAuthManagerAssetPairRates: AuthManagerProtocol {
    
    public func request() -> Observable<Result> {
        return request(withParams: false)
    }
    
    
    /// <#Description#>
    ///
    /// - Parameter params: Ignore base asset
    /// - Returns: <#return value description#>
    public func createPacket(withObserver observer: Any, params: (Bool)) -> LWPacketAssetPairRates {
        return Packet(observer: observer, ignoreBase: params)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        guard let rates = packet.assetPairRates else {
            return Result.success(withData: [])
        }
        return Result.success(withData: rates.map{$0 as! LWAssetPairRateModel})
    }
}

extension LWPacketAssetPairRates {
    convenience init(observer: Any, ignoreBase: Bool) {
        self.init()
        self.observer = observer
        self.ignoreBaseAsset = ignoreBase
    }
}
