//
//  LWRxAuthManagerOffchainCashOutSwift.swift
//  WalletCore
//
//  Created by Nacho Nachev on 03/11/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerOffchainCashOutSwift: NSObject {
    public typealias Packet = LWPacketOffchainCashOutSwift
    public typealias Result = ApiResult<LWModelOffchainResult>
    public typealias RequestParams = LWPacketOffchainCashOutSwift.Body

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

extension LWRxAuthManagerOffchainCashOutSwift: AuthManagerProtocol {
    public func request(withParams params: RequestParams) -> Observable<Result> {
        return Observable.create{observer in
            let packet = Packet(body: params, observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    func getErrorResult(fromPacket packet: LWPacketOffchainCashOutSwift) -> ApiResult<LWModelOffchainResult> {
        return ApiResult.error(withData: packet.errors)
    }
    
    func getSuccessResult(fromPacket packet: LWPacketOffchainCashOutSwift) -> ApiResult<LWModelOffchainResult> {
        guard let result = packet.model else {
            return ApiResult.error(withData: ["Message": "Missing data."])
        }
        
        return ApiResult.success(withData: result)
    }
    
    func getForbiddenResult(fromPacket packet: LWPacketOffchainCashOutSwift) -> ApiResult<LWModelOffchainResult> {
        return ApiResult.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: LWPacketOffchainCashOutSwift) -> ApiResult<LWModelOffchainResult> {
        return ApiResult.notAuthorized
    }
}
