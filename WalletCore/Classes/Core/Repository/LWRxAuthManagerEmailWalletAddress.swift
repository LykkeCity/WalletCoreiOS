//
//  LWRxAuthManagerEmailWalletAddress.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class LWRxAuthManagerEmailWalletAddress: NSObject  {
    
    public typealias Packet = LWPacketEmailPrivateWalletAddress
    public typealias Result = ApiResult<Void>
    public typealias RequestParams = (LWPrivateWalletModel)
    
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
extension LWRxAuthManagerEmailWalletAddress: AuthManagerProtocol {
    
    public func request(withParams params: RequestParams) -> Observable<Result> {
        return Observable.create{observer in
            let pack = Packet(observer: observer, wallet: params)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    func getErrorResult(fromPacket packet: Packet) -> Result {
        return Result.error(withData: packet.errors)
    }
    
    func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: Void())
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return Result.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return Result.notAuthorized
    }
}

public extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Self.E == ApiResult<Void> {
    public func filterSuccess() -> Driver<Void> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Driver<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketEmailPrivateWalletAddress {
    convenience init(observer: Any, wallet: LWPrivateWalletModel) {
        self.init()
        
        self.name = wallet.name
        self.address = wallet.address
        self.observer = observer
    }
}