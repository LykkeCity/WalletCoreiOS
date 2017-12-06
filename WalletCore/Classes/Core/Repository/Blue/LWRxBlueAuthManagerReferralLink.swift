//
//  LWRxBlueAuthManagerReferralLink.swift
//  WalletCore
//
//  Created by Vasil Garov on 12/1/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxBlueAuthManagerReferralLink: NSObject {
    
    public typealias Packet = ReferralLinkPacket
    public typealias Result = ApiResult<ReferralLinkModel>
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


extension LWRxBlueAuthManagerReferralLink: AuthManagerProtocol {
    public func request(withParams params: Void = Void()) -> Observable<Result> {
        return Observable.create{observer in
            let pack = Packet(observer: observer)
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
        guard let model = packet.model else {
            return Result.error(withData: ["Message":"Couldn't retreive referral link."])
        }
        
        return Result.success(withData: model)
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return Result.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return Result.notAuthorized
    }
}

public extension ObservableType where Self.E == ApiResult<ReferralLinkModel> {
    public func filterSuccess() -> Observable<ReferralLinkModel> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

