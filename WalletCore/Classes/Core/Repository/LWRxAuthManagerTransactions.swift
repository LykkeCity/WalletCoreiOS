//
//  LWRxAuthManagerTransactions.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/10/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerTransactions: NSObject{
    
    public typealias Packet = LWPacketTransactions
    public typealias Result = ApiResult<LWTransactionsModel>
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

extension LWRxAuthManagerTransactions: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: (String?)) -> LWPacketTransactions {
        return Packet(observer: observer, assetId: params)
    }

    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.model)
    }
}

public extension ObservableType where Self.E == ApiResult<LWTransactionsModel> {
    public func filterSuccess() -> Observable<LWTransactionsModel> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketTransactions {
    convenience init(observer: Any, assetId: String?) {
        self.init()
        
        if let assetId = assetId {
            self.assetId = NSString(string: assetId)
        }
        
        self.observer = observer
    }
}
