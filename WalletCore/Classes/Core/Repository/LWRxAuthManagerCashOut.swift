//
//  LWRxAuthManagerCashOut.swift
//  WalletCore
//
//  Created by Vasil Garov on 12/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerCashOut: NSObject {
    public typealias Packet = LWPacketCashOut
    public typealias Result = ApiResult<Bool>
    public typealias ResultType = Bool
    public typealias RequestParams = (LWPacketCashOutParams)

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

extension LWRxAuthManagerCashOut: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: (LWPacketCashOutParams)) -> LWPacketCashOut {
        return Packet(observer: observer, params: params)
    }

    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: true)
    }
}

extension LWPacketCashOut {
    convenience init(observer: Any, params: LWPacketCashOutParams) {
        self.init()
        self.observer = observer
        self.amount = params.amount as NSNumber
        self.assetId = params.assetId
        self.multiSig = params.multiSig
    }
}

public struct LWPacketCashOutParams {
    let amount: Decimal
    let assetId: String
    let multiSig: String
}
