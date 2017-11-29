//
//  LWRxBlueAuthManagerPledgePost.swift
//  WalletCore
//
//  Created by Vasil Garov on 11/28/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxBlueAuthManagerPledgePost: NSObject {
    
    public typealias Packet = PledgePostPacket
    public typealias Result = ApiResult<Void>
    public typealias RequestParams = PledgePostPacket.Body
    
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


extension LWRxBlueAuthManagerPledgePost: AuthManagerProtocol {
    public func request(withParams params: PledgePostPacket.Body) -> Observable<Result> {
        return Observable.create{observer in
            let pack = Packet(body: params, observer: observer)
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
