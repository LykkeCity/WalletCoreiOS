//
//  LWRxAuthManagerAccountExist.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/28/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerAccountExist: NSObject {

    public typealias Packet = LWPacketAccountExist
    public typealias Result = ApiResult<LWPacketAccountExist>
    public typealias ResultType = LWPacketAccountExist
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

extension LWRxAuthManagerAccountExist: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketAccountExist {
        return Packet(observer: observer, email: params)
    }
}

extension LWPacketAccountExist {
    convenience init(observer: Any, email: String) {
        self.init()
        self.observer = observer
        self.email = email
    }
}
