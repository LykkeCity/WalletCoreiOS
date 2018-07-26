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
    func request() -> Observable<ApiResult<[LWAssetModel]>>
}

public class LWRxAuthManagerBaseAssets: NSObject, LWRxAuthManagerBaseAssetsProtocol {

    public typealias Packet = LWPacketBaseAssets
    public typealias Result = ApiResult<[LWAssetModel]>
    public typealias ResultType = [LWAssetModel]
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

    public func request() -> Observable<ApiResult<[LWAssetModel]>> {
        return request(withParams: ())
    }

    public func request(withParams: RequestParams) -> Observable<Result> {
        return self.defaultRequestImplementation(with: ())
    }

    public func getErrorResult(fromPacket packet: Packet) -> Result {
        return Result.error(withData: packet.errors)
    }

    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: LWCache.instance().allAssets.map {$0 as? LWAssetModel}.flatMap {$0})
    }
}
