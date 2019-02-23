//
//  LWRxAuthManagerPostClientCodes.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/22/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerPostClientCodes: NSObject{
    
    public typealias Packet = LWPacketPostClientCodes
    public typealias Result = ApiResult<LWPacketPostClientCodes>
    public typealias ResultType = LWPacketPostClientCodes
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

extension LWRxAuthManagerPostClientCodes: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketPostClientCodes {
        return Packet(observer: observer, codeSms: params)
    }
}

extension LWPacketPostClientCodes {
    convenience init(observer: Any, codeSms: String) {
        self.init()
        self.observer = observer
        self.codeSms = codeSms
    }
}


