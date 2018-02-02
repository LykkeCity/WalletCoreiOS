//
//  LWRxAuthManagerPushNotificationsGet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/29/17.
//
//

import Foundation
import RxSwift


public class LWRxAuthManagerPushNotificationsGet:  NSObject{
    
    public typealias Packet = LWPacketPushSettingsGet
    public typealias Result = ApiResult<LWPacketPushSettingsGet>
    public typealias ResultType = LWPacketPushSettingsGet
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

extension LWRxAuthManagerPushNotificationsGet: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketPushSettingsGet {
        return Packet(observer: observer)
    }
}

extension LWPacketPushSettingsGet {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}

