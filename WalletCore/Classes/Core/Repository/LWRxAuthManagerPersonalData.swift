//
//  LWRxAuthManagerPersonalData.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/23/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerPersonalData: NSObject{
    
    public typealias Packet = LWPacketPersonalData
    public typealias Result = ApiResult<LWPacketPersonalData>
    public typealias ResultType = LWPacketPersonalData
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

extension LWRxAuthManagerPersonalData: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketPersonalData {
        return Packet(observer: observer)
    }
    
    public func request(withParams params: Void) -> Observable<ApiResult<LWPacketPersonalData>> {
        if let personalData = LWKeychainManager.instance().personalData() {
            let packet = Packet()
            packet.data = personalData
            
            return Observable
                .just(ApiResult.success(withData: packet))
                .startWith(ApiResult.loading)
        }
        
        return self.defaultRequestImplementation(with: ())
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketPersonalData> {
    public func filterSuccess() -> Observable<LWPacketPersonalData> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketPersonalData {
    convenience init(observer: Any) {
        self.init()
        
        self.observer = observer
    }
}


