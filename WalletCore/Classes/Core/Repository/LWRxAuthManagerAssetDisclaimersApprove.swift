//
//  LWRxAuthManagerAssetDisclaimersApprove.swift
//  WalletCore
//
//  Created by Georgi Stanev on 11.05.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerAssetDisclaimersApprove: NSObject {
    
    public typealias Packet = LWPacketAssetDisclaimersApprove
    public typealias Result = ApiResult<AssetDisclaimerId>
    public typealias ResultType = AssetDisclaimerId
    public typealias RequestParams = AssetDisclaimerId
    
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

extension LWRxAuthManagerAssetDisclaimersApprove: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: RequestParams) -> Packet {
        return Packet(observer: observer, disclaimerId: params)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.disclaimerId)
    }
}
