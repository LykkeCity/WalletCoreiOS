//
//  LWRxAuthManagerHistory.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/11/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerHistory: NSObject{
    
    public typealias Packet = LWPacketGetHistory
    public typealias Result = ApiResultList<LWBaseHistoryItemType>
    public typealias ResultType = LWBaseHistoryItemType
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
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        let data: [LWBaseHistoryItemType] = LWHistoryManager
            .prepareHistory(packet.historyArray, marginal: [])
            .flatMap{$0 as? [LWBaseHistoryItemType] ?? []}
        
        return Result.success(withData: data)
    }
}

public extension ObservableType where Self.E == ApiResultList<LWBaseHistoryItemType> {
    public func filterSuccess() -> Observable<[LWBaseHistoryItemType]> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketGetHistory {
    convenience init(observer: Any, assetId: String?) {
        self.init()
        
        self.assetId = assetId
        self.observer = observer
    }
}
