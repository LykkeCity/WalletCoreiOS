//
//  LWRxAuthenticationManagerAuth.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/17/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerAuth: NSObject{
    
    public typealias Packet = LWPacketAuthentication
    public typealias Result = ApiResult<LWPacketAuthentication>
    public typealias RequestParams = (LWAuthenticationData)
    
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

extension LWRxAuthManagerAuth: AuthManagerProtocol{
    public func request(withParams params: RequestParams) -> Observable<Result> {
        return Observable.create{observer in
            let pack = Packet(observer: observer, data: params)
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
        return Result.success(withData: packet)
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return Result.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return Result.notAuthorized
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketAuthentication> {
    public func filterSuccess() -> Observable<LWPacketAuthentication> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }

    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketAuthentication {
    convenience init(observer: Any, data: LWAuthenticationData) {
        self.init()
        
        self.authenticationData = data
        self.observer = observer
    }
}

