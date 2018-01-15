//
//  LWRxAuthManagerAppSettings.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/28/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerAppSettings:  NSObject{
    
    public typealias Packet = LWPacketAppSettings
    public typealias Result = ApiResult<LWPacketAppSettings>
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

extension LWRxAuthManagerAppSettings: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketAppSettings {
        return Packet(observer: observer)
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketAppSettings> {
    public func filterSuccess() -> Observable<LWPacketAppSettings> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketAppSettings {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}
