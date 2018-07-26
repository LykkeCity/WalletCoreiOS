//
//  LWRxAuthManagerAppSettings.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/28/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerAppSettings: NSObject {

    public typealias Packet = LWPacketAppSettings
    public typealias Result = ApiResult<LWPacketAppSettings>
    public typealias ResultType = LWPacketAppSettings
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

extension LWRxAuthManagerAppSettings: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketAppSettings {
        return Packet(observer: observer)
    }
}

extension LWPacketAppSettings {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}
