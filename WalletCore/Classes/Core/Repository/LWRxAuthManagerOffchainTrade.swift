//
//  LWRxAuthManagerOffchainTrade.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/20/17.
//  Copyright © 2017 Lykke. All rights reserved.
//
import Foundation
import RxSwift

public class LWRxAuthManagerOffchainTrade : NSObject{
    
    public typealias Packet = LWPacketOffchainTrade
    public typealias Result = ApiResult<LWModelOffchainResult>
    public typealias RequestParams = (LWPacketOffchainTrade.Body)
    
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

extension LWRxAuthManagerOffchainTrade: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: (LWPacketOffchainTrade.Body)) -> LWPacketOffchainTrade {
        return Packet(body: params, observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.model!)
    }
}

public extension ObservableType where Self.E == [ApiResult<LWModelOffchainResult>] {
    public func filterSuccess() -> Observable<[LWModelOffchainResult]> {
        return filter{ $0.allSuccessful() }
               .map{ $0.filterSuccess() }
    }
}

extension Array where Element == ApiResult<LWModelOffchainResult> {
    func allSuccessful() -> Bool {
        return first{!$0.isSuccess} == nil
    }
    
    func filterSuccess() -> [LWModelOffchainResult] {
        return map{ $0.getSuccess() }
               .filter{ $0 != nil }
               .map{ $0! }
    }
}

public extension ObservableType where Self.E == ApiResult<LWModelOffchainResult> {
    public func filterSuccess() -> Observable<LWModelOffchainResult> {
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

