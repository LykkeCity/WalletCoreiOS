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
    func request() -> Observable<ApiResultList<LWAssetPairRateModel>>
    
    /// <#Description#>
    ///
    /// - Parameter params: Ignore base asset
    /// - Returns: <#return value description#>
    func request(withParams params: Bool) -> Observable<ApiResultList<LWAssetPairRateModel>>
}

public class LWRxAuthManagerAssetPairRates: NSObject, LWRxAuthManagerAssetPairRatesProtocol  {
    
    public typealias Packet = LWPacketAssetPairRates
    public typealias Result = ApiResultList<LWAssetPairRateModel>
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
    public func request(withParams params: RequestParams) -> Observable<Result> {
        return Observable.create{observer in
            let packet = Packet(observer: observer, ignoreBase: params)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    func getErrorResult(fromPacket packet: Packet) -> Result {
        return Result.error(withData: packet.errors)
    }
    
    func getSuccessResult(fromPacket packet: Packet) -> Result {
        guard let rates = packet.assetPairRates else {
            return Result.success(withData: [])
        }
        return Result.success(withData: rates.map{$0 as! LWAssetPairRateModel})
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return Result.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return Result.notAuthorized
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
