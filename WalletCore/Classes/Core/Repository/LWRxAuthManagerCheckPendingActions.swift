//
//  LWRxAuthManagerCheckPendingActions.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerCheckPendingActions: NSObject {

    public typealias Packet = LWPacketCheckPendingActions
    public typealias Result = ApiResult<LWPacketCheckPendingActions>
    public typealias ResultType = LWPacketCheckPendingActions
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

extension LWRxAuthManagerCheckPendingActions: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketCheckPendingActions {
        return Packet(observer: observer)
    }
}
