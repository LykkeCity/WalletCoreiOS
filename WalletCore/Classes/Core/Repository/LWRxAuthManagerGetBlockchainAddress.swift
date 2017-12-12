//
//  LWRxAuthManagerGetBlockchainAddress.swift
//  WalletCore
//
//  Created by Nacho Nachev  on 10.12.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerGetBlockchainAddress: NSObject {
    public typealias Packet = LWPacketGetBlockchainAddress
    public typealias Result = ApiResult<LWPacketGetBlockchainAddress>
    public typealias RequestParams = String
    
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


extension LWRxAuthManagerGetBlockchainAddress: AuthManagerProtocol {
    public func request(withParams params: String) -> Observable<Result> {
        return Observable.create{ observer in
            let packet = Packet(observer: observer, assetId: params)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    func getErrorResult(fromPacket packet: Packet) -> Result {
        return ApiResult.error(withData: packet.errors)
    }
    
    func getSuccessResult(fromPacket packet: Packet) -> Result {
        return ApiResult.success(withData: packet)
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return ApiResult.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return ApiResult.notAuthorized
    }
}


extension LWPacketGetBlockchainAddress {
    convenience init(observer: Any, assetId: LWRxAuthManagerGetBlockchainAddress.RequestParams) {
        self.init()
        self.observer = observer
        self.assetId = assetId
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketGetBlockchainAddress> {
    public func filterSuccess() -> Observable<LWPacketGetBlockchainAddress> {
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
