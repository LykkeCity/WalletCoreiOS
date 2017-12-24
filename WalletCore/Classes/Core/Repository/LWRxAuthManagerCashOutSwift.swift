//
//  LWRxAuthManagerCashOutSwift.swift
//  WalletCore
//
//  Created by Nacho Nachev on 2.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerCashOutSwift: NSObject {
    public typealias Packet = LWPacketCashOutSwift
    public typealias Result = ApiResult<Void>
    public typealias RequestParams = LWPacketCashOutSwift.Body
    
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

extension LWRxAuthManagerCashOutSwift: AuthManagerProtocol {
    
    public func request(withParams params: RequestParams) -> Observable<Result> {
        return Observable.create { observer in
            let packet = Packet(body: params, observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    func getErrorResult(fromPacket packet: LWPacketCashOutSwift) -> ApiResult<Void> {
        return ApiResult.error(withData: packet.errors)
    }
    
    func getSuccessResult(fromPacket packet: LWPacketCashOutSwift) -> ApiResult<Void> {
        return ApiResult.success(withData: Void())
    }
    
    func getForbiddenResult(fromPacket packet: LWPacketCashOutSwift) -> ApiResult<Void> {
        return ApiResult.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: LWPacketCashOutSwift) -> ApiResult<Void> {
        return ApiResult.notAuthorized
    }
}

public extension ObservableType where Self.E == ApiResult<Void> {
    public func filterSuccess() -> Observable<Void> {
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
