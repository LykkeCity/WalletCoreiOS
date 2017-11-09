//
//  LWRxAuthManagerSwiftCredentials.swift
//  LykkeWallet
//
//  Created by Bozidar Nikolic on 7/26/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerSwiftCredentials: NSObject{
    
    public typealias Packet = LWPacketSwiftCredential
    public typealias Result = ApiResult<LWPacketSwiftCredential>
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

extension LWRxAuthManagerSwiftCredentials: AuthManagerProtocol{
    public func request(withParams params: RequestParams) -> Observable<Result> {
        return Observable.create{observer in
            let packet = Packet(observer: observer, assetId: params)
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

public extension ObservableType where Self.E == ApiResult<LWPacketSwiftCredential> {
    public func filterSuccess() -> Observable<LWPacketSwiftCredential> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketSwiftCredential {
    convenience init(observer: Any, assetId: String) {
        self.init()
        self.observer = observer
        self.identity = assetId
    }
}


