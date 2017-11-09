//
//  LWRxAuthManagerPhoneVerificationPin.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/25/17.
//
//


import Foundation
import RxSwift

public class LWRxAuthManagerPhoneVerificationPin:  NSObject{
    
    public typealias Packet = LWPacketPhoneVerificationGet
    public typealias Result = ApiResult<LWPacketPhoneVerificationGet>
    public typealias RequestParams = (phone: String, pin: String)
    
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

extension LWRxAuthManagerPhoneVerificationPin: AuthManagerProtocol{

    func request(withParams params: RequestParams) -> Observable<Result> {
        return Observable.create{observer in
            let pack = Packet(observer: observer, phone: params.phone, pin: params.pin)
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

public extension ObservableType where Self.E == ApiResult<LWPacketPhoneVerificationGet> {
    public func filterSuccess() -> Observable<LWPacketPhoneVerificationGet> {
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

extension LWPacketPhoneVerificationGet {
    convenience init(observer: Any, phone: String, pin: String) {
        self.init()
        
        self.phone = phone
        self.code = pin
        self.observer = observer
    }
}

