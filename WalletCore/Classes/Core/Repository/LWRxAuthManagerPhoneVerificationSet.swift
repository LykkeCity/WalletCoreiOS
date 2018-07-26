//
//  LWRxAuthManagerPhoneVerificationSet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/25/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerPhoneVerificationSet: NSObject {

    public typealias Packet = LWPacketPhoneVerificationSet
    public typealias Result = ApiResult<LWPacketPhoneVerificationSet>
    public typealias ResultType = LWPacketPhoneVerificationSet
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

extension LWRxAuthManagerPhoneVerificationSet: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketPhoneVerificationSet {
        return Packet(observer: observer, data: params)
    }
}

extension LWPacketPhoneVerificationSet {
    convenience init(observer: Any, data: String) {
        self.init()

        self.phone = data
        self.observer = observer
    }
}
