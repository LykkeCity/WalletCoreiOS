//
//  LWRxAuthManagerAssetDisclaimersGet.swift
//  WalletCore
//
//  Created by Georgi Stanev on 11.05.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerAssetDisclaimersGet: NSObject {
    
    public typealias Packet = LWPacketAssetDisclaimersGet
    public typealias Result = ApiResult<[LWModelAssetDisclaimer]>
    public typealias ResultType = [LWModelAssetDisclaimer]
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

extension LWRxAuthManagerAssetDisclaimersGet: AuthManagerProtocol {
    public func createPacket(withObserver observer: Any, params: RequestParams) -> Packet {
        return Packet(observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.assetDisclaimers ?? [])
    }
}
