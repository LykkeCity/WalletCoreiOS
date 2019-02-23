//
//  LWRxAuthManagerCashOutSwift.swift
//  WalletCore
//
//  Created by Nacho Nachev on 2.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerCashOutSwift: NSObject {
    public typealias Packet = LWPacketCashOutSwift
    public typealias Result = ApiResult<Void>
    public typealias ResultType = Void
    public typealias RequestParams = LWPacketCashOutSwift.Body
    
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

extension LWRxAuthManagerCashOutSwift: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: LWPacketCashOutSwift.Body) -> LWPacketCashOutSwift {
        return Packet(body: params, observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: LWPacketCashOutSwift) -> ApiResult<Void> {
        return ApiResult.success(withData: Void())
    }
}
