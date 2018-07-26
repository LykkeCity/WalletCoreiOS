//
//  LWRxAuthManagerHistory.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/11/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerHistory: NSObject {

    public typealias Packet = LWPacketGetHistory
    public typealias Result = ApiResult<[LWBaseHistoryItemType]>
    public typealias ResultType = [LWBaseHistoryItemType]
    public typealias RequestParams = (String?)

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

extension LWRxAuthManagerHistory: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: (String?)) -> LWPacketGetHistory {
        return Packet(observer: observer, assetId: params)
    }

    public func request() -> Observable<ApiResult<[LWBaseHistoryItemType]>> {
        return self.request(withParams: nil)
    }

    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        let data: [LWBaseHistoryItemType] = LWHistoryManager
            .prepareHistory(packet.historyArray, marginal: [])
            .flatMap {$0 as? [LWBaseHistoryItemType] ?? []}

        return Result.success(withData: data)
    }
}

extension LWPacketGetHistory {
    convenience init(observer: Any, assetId: String?) {
        self.init()

        self.assetId = assetId
        self.observer = observer
    }
}
