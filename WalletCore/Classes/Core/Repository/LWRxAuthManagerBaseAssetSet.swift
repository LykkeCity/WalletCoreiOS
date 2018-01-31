//
//  LWRxAuthManagerBaseAssetSet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/29/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerBaseAssetSet:  NSObject{
    
    public typealias Packet = LWPacketBaseAssetSet
    public typealias Result = ApiResult<LWPacketBaseAssetSet>
    public typealias ResultType = LWPacketBaseAssetSet
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

extension LWRxAuthManagerBaseAssetSet: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketBaseAssetSet {
        return Packet(observer: observer, identity: params)
    }
    
    public func onSuccess(packet: Packet) {
        guard let observer = packet.observer as? AnyObserver<Result> else { return }
        LWCache.instance().baseAssetId = packet.identity
        observer.onNext(getSuccessResult(fromPacket: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketBaseAssetSet> {
    public func filterSuccess() -> Observable<LWPacketBaseAssetSet> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketBaseAssetSet {
    convenience init(observer: Any, identity: String) {
        self.init()
        self.observer = observer
        self.identity = identity
    }
}

