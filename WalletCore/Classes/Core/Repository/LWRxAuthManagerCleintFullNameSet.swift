//
//  LWRxAuthManagerCleintFullNameSet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/24/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerCleintFullNameSet: NSObject {

    public typealias Packet = LWPacketClientFullNameSet
    public typealias Result = ApiResult<LWPacketClientFullNameSet>
    public typealias ResultType = LWPacketClientFullNameSet
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

extension LWRxAuthManagerCleintFullNameSet: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketClientFullNameSet {
        return Packet(observer: observer, data: params)
    }
}

extension LWPacketClientFullNameSet {
    convenience init(observer: Any, data: String) {
        self.init()

        self.fullName = data
        self.observer = observer
    }
}
