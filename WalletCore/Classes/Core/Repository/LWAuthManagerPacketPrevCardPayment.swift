//
//  LWAuthManagerPacketPrevCardPayment.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 8/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWAuthManagerPacketPrevCardPayment: NSObject{
    
    public typealias Packet = LWPacketPrevCardPayment
    public typealias Result = ApiResult<LWPersonalDataModel>
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

extension LWAuthManagerPacketPrevCardPayment: AuthManagerProtocol{
    
    public func request(withParams params: RequestParams = Void()) -> Observable<Result> {
        return Observable.create{observer in
            let packet = Packet(observer: observer)
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
        return Result.success(withData: packet.lastPaymentPersonalData)
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return Result.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return Result.notAuthorized
    }
    
    
    /*override func onNotAuthorized(withPacket packet: LWPacketPrevCardPayment) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPersonalDataModel>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketPrevCardPayment) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPersonalDataModel>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketPrevCardPayment) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPersonalDataModel>> else {return}
        observer.onNext(.success(withData: packet.lastPaymentPersonalData))
        observer.onCompleted()
    }*/
}

public extension ObservableType where Self.E == ApiResult<LWPersonalDataModel> {
    public func filterError() -> Observable<[AnyHashable : Any]> {
        return map{$0.getError()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func filterSuccess() -> Observable<LWPersonalDataModel> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
