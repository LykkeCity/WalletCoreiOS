//
//  LWRxAuthManagerAllCurrencies.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/28/17.
//
//


import Foundation
import RxSwift

public class LWRxAuthManagerAllCurrencies:  NSObject {
    
    public typealias Packet = LWPacketAllAssets
    public typealias Result = ApiResult<LWPacketAllAssets>
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

extension LWRxAuthManagerAllCurrencies: AuthManagerProtocol{
   
    public func request(withParams params:RequestParams = Void()) -> Observable<Result> {
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
        return Result.success(withData: packet)
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return Result.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return Result.notAuthorized
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketAllAssets> {
    public func filterSuccess() -> Observable<LWPacketAllAssets> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketAllAssets {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}



