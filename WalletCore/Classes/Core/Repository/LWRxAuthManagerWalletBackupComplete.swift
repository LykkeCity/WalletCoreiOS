//
//  LWRxAuthManagerWalletBackupComplete.swift
//  WalletCore
//
//  Created by Nacho Nachev on 23.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerWalletBackupComplete: NSObject {
    
    public typealias Packet = LWPacketSaveBackupState
    public typealias Result = ApiResult<LWPacketSaveBackupState>
    public typealias ResultType = LWPacketSaveBackupState
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


extension LWRxAuthManagerWalletBackupComplete: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketSaveBackupState {
        return Packet(observer: observer)
    }
}


extension LWPacketSaveBackupState {
    
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
    
}
