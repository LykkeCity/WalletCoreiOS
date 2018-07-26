//
//  LWRxAuthManagerAllCurrencies.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/28/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerAllCurrencies: NSObject {

    public typealias Packet = LWPacketAllAssets
    public typealias Result = ApiResult<LWPacketAllAssets>
    public typealias ResultType = LWPacketAllAssets
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

extension LWRxAuthManagerAllCurrencies: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketAllAssets {
        return Packet(observer: observer)
    }
}

extension LWPacketAllAssets {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}
