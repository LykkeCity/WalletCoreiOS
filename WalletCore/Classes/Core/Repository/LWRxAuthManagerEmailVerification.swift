//
//  LWRxAuthManagerEmailVerification.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/18/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerEmailVerification: NSObject {

    public typealias Packet = LWPacketEmailVerificationSet
    public typealias Result = ApiResult<LWPacketEmailVerificationSet>
    public typealias ResultType = LWPacketEmailVerificationSet
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

extension LWRxAuthManagerEmailVerification: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketEmailVerificationSet {
        return Packet(observer: observer, data: params)
    }
}

extension LWPacketEmailVerificationSet {
    convenience init(observer: Any, data: String) {
        self.init()

        self.email = data
        self.observer = observer
    }
}
