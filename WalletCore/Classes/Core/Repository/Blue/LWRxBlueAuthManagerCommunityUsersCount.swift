//
//  LWRxBlueAuthManagerCommunityUsersCount.swift
//  WalletCore
//
//  Created by Nacho Nachev on 4.12.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxBlueAuthManagerCommunityUsersCount: NSObject {
    public typealias Packet = CommunityUsersCountPacket
    public typealias Result = ApiResult<Int>
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


extension LWRxBlueAuthManagerCommunityUsersCount: AuthManagerProtocol {
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
        guard let count = packet.count else {
            return Result.error(withData: ["Message":"Couldn't retreive community size."])
        }
        
        return Result.success(withData: count)
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return Result.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return Result.notAuthorized
    }
}


public extension ObservableType where Self.E == ApiResult<Int> {
    public func filterSuccess() -> Observable<Int> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
