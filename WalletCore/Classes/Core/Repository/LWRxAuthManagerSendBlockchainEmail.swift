//
//  LWRxAuthManagerSendBlockchainEmail.swift
//  WalletCore
//
//  Created by Nacho Nachev  on 11.12.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class LWRxAuthManagerSendBlockchainEmail: NSObject {
    public typealias Packet = LWPacketSendBlockchainEmail
    public typealias Result = ApiResult<LWPacketSendBlockchainEmail>
    public typealias RequestParams = (assetId: String, address: String)
    
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


extension LWRxAuthManagerSendBlockchainEmail: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: (assetId: String, address: String)) -> LWPacketSendBlockchainEmail {
        return Packet(observer: observer, params: params)
    }
}


extension LWPacketSendBlockchainEmail {
    convenience init(observer: Any, params: LWRxAuthManagerSendBlockchainEmail.RequestParams) {
        self.init()
        self.observer = observer
        self.assetId = params.assetId
        self.address = params.address
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketSendBlockchainEmail> {
    public func filterSuccess() -> Observable<LWPacketSendBlockchainEmail> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable<[AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func filterForbidden() -> Observable<Void> {
        return filter{$0.isForbidden}.map{_ in Void()}
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
