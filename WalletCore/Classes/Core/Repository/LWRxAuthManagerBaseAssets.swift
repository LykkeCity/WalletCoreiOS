//
//  LWRxAuthManagerBaseAssets.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 23.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public protocol LWRxAuthManagerBaseAssetsProtocol {
    func request() -> Observable<ApiResultList<LWAssetModel>>
}

public class LWRxAuthManagerBaseAssets: NSObject, LWRxAuthManagerBaseAssetsProtocol {

    public typealias Packet = LWPacketBaseAssets
    public typealias Result = ApiResultList<LWAssetModel>
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

extension LWRxAuthManagerBaseAssets: AuthManagerProtocol {
    public func createPacket(withObserver observer: Any, params: ()) -> LWPacketBaseAssets {
        return Packet(observer: observer)
    }
    
    public func request() -> Observable<ApiResultList<LWAssetModel>> {
        return request(withParams:()).map{ result -> ApiResultList<LWAssetModel> in
            switch result {
            case .error(let data): return .error(withData: data)
            case .loading: return .loading
            case .notAuthorized: return .notAuthorized
            case .forbidden: return .forbidden
            case .success(let data): return .success(withData: data)
            }
        }
    }
    
    public func request(withParams: RequestParams) -> Observable<Result> {
        return self.defaultRequestImplementation(with: ())
    }
    
    public func getErrorResult(fromPacket packet: Packet) -> Result {
        return Result.error(withData: packet.errors)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: LWCache.instance().allAssets.map{$0 as! LWAssetModel})
    }
}

