//
//  LWRxAuthenticationManagerAuth.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/17/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerAuth: NSObject {

    public typealias Packet = LWPacketAuthentication
    public typealias Result = ApiResult<LWPacketAuthentication>
    public typealias ResultType = LWPacketAuthentication
    public typealias RequestParams = (LWAuthenticationData)

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

extension LWRxAuthManagerAuth: AuthManagerProtocol {
    public func createPacket(withObserver observer: Any, params: (LWAuthenticationData)) -> LWPacketAuthentication {
        return Packet(observer: observer, data: params)
    }
}

extension LWPacketAuthentication {
    convenience init(observer: Any, data: LWAuthenticationData) {
        self.init()

        self.authenticationData = data
        self.observer = observer
    }
}
