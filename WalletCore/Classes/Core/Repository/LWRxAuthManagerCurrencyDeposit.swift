//
//  LWRxAuthManagerCurrencyDeposit.swift
//  WalletCore
//
//  Created by Georgi Stanev on 17.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerCurrencyDeposit: NSObject {
    public typealias Packet = LWPacketCurrencyDeposit
    public typealias Result = ApiResult<LWPacketCurrencyDeposit>
    public typealias ResultType = LWPacketCurrencyDeposit
    public typealias RequestParams = (assetId: String, balanceChange: Decimal)

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

extension LWRxAuthManagerCurrencyDeposit: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: (assetId: String, balanceChange: Decimal)) -> LWPacketCurrencyDeposit {
        return Packet(observer: observer, params: params)
    }
}

extension LWPacketCurrencyDeposit {
    convenience init(observer: Any, params: LWRxAuthManagerCurrencyDeposit.RequestParams) {
        self.init()
        self.observer = observer
        self.assetId = params.assetId
        self.balanceChange = NSNumber(value: params.balanceChange.doubleValue)
    }
}
