//
//  LWRxAuthManagerSendBlockchainEmail.swift
//  WalletCore
//
//  Created by Nacho Nachev  on 11.12.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class LWRxAuthManagerSendBlockchainEmail: NSObject {
    public typealias Packet = LWPacketSendBlockchainEmail
    public typealias Result = ApiResult<LWPacketSendBlockchainEmail>
    public typealias ResultType = LWPacketSendBlockchainEmail
    public typealias RequestParams = (assetId: String, address: String)

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

extension LWRxAuthManagerSendBlockchainEmail: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: (assetId: String, address: String)) -> LWPacketSendBlockchainEmail {
        return Packet(observer: observer, params: params)
    }
}

extension LWPacketSendBlockchainEmail {
    convenience init(observer: Any, params: LWRxAuthManagerSendBlockchainEmail.RequestParams) {
        self.init()
        self.observer = observer
        self.assetId = params.assetId
        self.address = params.address
    }
}
