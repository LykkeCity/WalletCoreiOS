//
//  LWRxAuthManagerOffchainCashOutSwift.swift
//  WalletCore
//
//  Created by Nacho Nachev on 03/11/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerOffchainCashOutSwift: NSObject {
    public typealias Packet = LWPacketOffchainCashOutSwift
    public typealias Result = ApiResult<LWModelOffchainResult>
    public typealias ResultType = LWModelOffchainResult
    public typealias RequestParams = LWPacketOffchainCashOutSwift.Body

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

extension LWRxAuthManagerOffchainCashOutSwift: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: LWPacketOffchainCashOutSwift.Body) -> LWPacketOffchainCashOutSwift {
        return Packet(body: params, observer: observer)
    }

    public func getSuccessResult(fromPacket packet: LWPacketOffchainCashOutSwift) -> ApiResult<LWModelOffchainResult> {
        guard let result = packet.model else {
            return ApiResult.error(withData: ["Message": "Missing data."])
        }

        return ApiResult.success(withData: result)
    }
}
