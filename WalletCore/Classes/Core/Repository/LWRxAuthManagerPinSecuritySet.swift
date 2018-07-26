//
//  LWRxAuthManagerPinSecuritySet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/21/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerPinSecuritySet: NSObject {

    public typealias Packet = LWPacketPinSecuritySet
    public typealias Result = ApiResult<LWPacketPinSecuritySet>
    public typealias ResultType = LWPacketPinSecuritySet
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

extension LWRxAuthManagerPinSecuritySet: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketPinSecuritySet {
        return Packet(observer: observer, data: params)
    }
}

extension LWPacketPinSecuritySet {
    convenience init(observer: Any, data: String) {
        self.init()

        self.pin = data
        self.observer = observer
    }
}
