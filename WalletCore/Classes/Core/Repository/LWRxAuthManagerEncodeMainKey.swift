//
//  LWRxAuthManagerEncodeMainKey.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/23/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerEncodeMainKey : NSObject{
    
    public typealias Packet = LWPacketEncodedMainKey
    public typealias Result = ApiResult<LWPacketEncodedMainKey>
    public typealias ResultType = LWPacketEncodedMainKey
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

extension LWRxAuthManagerEncodeMainKey: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketEncodedMainKey {
        return Packet(observer: observer, accessToken: params)
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketEncodedMainKey> {
    public func filterSuccess() -> Observable<LWPacketEncodedMainKey> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func filterForbidden() -> Observable<Void> {
        return filter{$0.isForbidden}.map{_ in Void()}
    }
    
    public func filterError() -> Observable<[AnyHashable: Any]> {
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketEncodedMainKey {
    convenience init(observer: Any, accessToken: String) {
        self.init()
        self.observer = observer
        self.accessToken = accessToken
    }
}
