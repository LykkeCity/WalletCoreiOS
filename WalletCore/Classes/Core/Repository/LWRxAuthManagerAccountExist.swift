//
//  LWRxAuthManagerAccountExist.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/28/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerAccountExist : NSObject{
    
    public typealias Packet = LWPacketAccountExist
    public typealias Result = ApiResult<LWPacketAccountExist>
    public typealias RequestParams = (String)
    
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

extension LWRxAuthManagerAccountExist: AuthManagerProtocol{
    
    public func request(withParams params: RequestParams) -> Observable<Result> {
        return Observable.create{observer in
            
            let packet = Packet(observer: observer, email: params)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    func getErrorResult(fromPacket packet: Packet) -> Result {
        return Result.error(withData: packet.errors)
    }
    
    func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet)
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return Result.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return Result.notAuthorized
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketAccountExist> {
    public func filterSuccess() -> Observable<LWPacketAccountExist> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketAccountExist {
    convenience init(observer: Any, email: String) {
        self.init()
        self.observer = observer
        self.email = email
    }
}
