//
//  LWAuthManagerPacketPrevCardPayment.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 8/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWAuthManagerPacketPrevCardPayment: LWRxAuthManagerBase<LWPacketPrevCardPayment> {
    
    public func requestPersonalData() -> Observable<ApiResult<LWPersonalDataModel>> {
        return Observable.create{observer in
            let packet = LWPacketPrevCardPayment(observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketPrevCardPayment) {
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
    }
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
