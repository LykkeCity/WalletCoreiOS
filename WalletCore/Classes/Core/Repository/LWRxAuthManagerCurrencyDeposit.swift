//
//  LWRxAuthManagerCurrencyDeposit.swift
//  WalletCore
//
//  Created by Georgi Stanev on 17.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerCurrencyDeposit: NSObject {
    public typealias Packet = LWPacketCurrencyDeposit
    public typealias Result = ApiResult<LWPacketCurrencyDeposit>
    public typealias RequestParams = (assetId: String, balanceChange: Decimal)
    
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


extension LWRxAuthManagerCurrencyDeposit: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: (assetId: String, balanceChange: Decimal)) -> LWPacketCurrencyDeposit {
        return Packet(observer: observer, params: params)
    }
}


extension LWPacketCurrencyDeposit {
    convenience init(observer: Any, params: LWRxAuthManagerCurrencyDeposit.RequestParams) {
        self.init()
        self.observer = observer
        self.assetId = params.assetId
        self.balanceChange = NSNumber(value: params.balanceChange.doubleValue)
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketCurrencyDeposit> {
    public func filterSuccess() -> Observable<LWPacketCurrencyDeposit> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable<[AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func filterForbidden() -> Observable<Void> {
        return filter{$0.isForbidden}.map{_ in Void()}
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

public extension ObservableType where Self.E == ApiResult<LWRxAuthManagerCurrencyDeposit.RequestParams> {
    public func filterSuccess() -> Observable<LWRxAuthManagerCurrencyDeposit.RequestParams> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable<[AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func filterForbidden() -> Observable<Void> {
        return filter{$0.isForbidden}.map{_ in Void()}
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
