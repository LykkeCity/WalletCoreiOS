//
//  LWRxAuthManagerAssetPairRate.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerAssetPairRate: NSObject {

    public typealias Packet = LWPacketAssetPairRate
    public typealias Result = ApiResult<LWAssetPairRateModel>
    public typealias ResultType = LWAssetPairRateModel
    public typealias RequestParams = (String)

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

extension LWRxAuthManagerAssetPairRate: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketAssetPairRate {
        return Packet(observer: observer, pairId: params)
    }

    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.assetPairRate)
    }
}

extension LWPacketAssetPairRate {
    convenience init(observer: Any, pairId: String) {
        self.init()
        self.observer = observer
        self.identity = pairId
    }
}
