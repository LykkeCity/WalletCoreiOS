//
//  LWRxAuthManagerGraphPeriods.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

import RxSwift

public class LWRxAuthManagerGraphPeriods: NSObject {

    public typealias Packet = LWPacketGraphPeriods
    public typealias Result = ApiResult<LWPacketGraphPeriods>
    public typealias ResultType = LWPacketGraphPeriods
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

extension LWRxAuthManagerGraphPeriods: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketGraphPeriods {
        return Packet(observer: observer)
    }
}
