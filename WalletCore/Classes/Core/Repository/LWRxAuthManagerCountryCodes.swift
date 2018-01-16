//
//  LWRxAuthManagerCountryCodes.swift
//  Pods
//
//  Created by Georgi Stanev on 8/21/17.
//
//

import Foundation
import Foundation
import RxSwift

public class LWRxAuthManagerCountryCodes: NSObject{
    
    public typealias Packet = LWPacketCountryCodes
    public typealias Result = ApiResultList<LWCountryModel>
    public typealias ResultType = LWCountryModel
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

extension LWRxAuthManagerCountryCodes: AuthManagerProtocol{
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketCountryCodes {
        return Packet(observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.countries.map{$0 as! LWCountryModel})
    }
}

public extension ObservableType where Self.E == ApiResultList<LWCountryModel> {
    public func filterSuccess() -> Observable<[LWCountryModel]> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

