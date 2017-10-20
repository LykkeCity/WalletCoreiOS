//
//  LWAuthManagerPacketGetPaymentUrl.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 8/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//
import Foundation
import RxSwift

public class LWAuthManagerPacketGetPaymentUrl: LWRxAuthManagerBase<LWPacketGetPaymentUrl> {
    
    public func requestPaymentUrl(withParams params: LWPacketGetPaymentUrlParams) -> Observable<ApiResult<LWPacketGetPaymentUrl>> {
        
        return Observable.create{observer in
            let packet = LWPacketGetPaymentUrl(observer: observer, params: params)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketGetPaymentUrl) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketGetPaymentUrl>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketGetPaymentUrl) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketGetPaymentUrl>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketGetPaymentUrl) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketGetPaymentUrl>> else {return}
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketGetPaymentUrl> {
    public func filterError() -> Observable<[AnyHashable : Any]> {
        return map{$0.getError()}.filterNil()
    }
    
    public func filterSuccess() -> Observable<LWPacketGetPaymentUrl> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketGetPaymentUrl {
    convenience init(observer: Any, params: LWPacketGetPaymentUrlParams) {
        self.init()
        self.observer = observer
        self.parameters = params.toDictionaty()
    }
}

public struct LWPacketGetPaymentUrlParams {
    let amount: String
    let firstName: String
    let lastName: String
    let city: String
    let zip: String
    let address: String
    let country: String
    let email: String
    let phone: String
    let assetId: String
}

fileprivate extension LWPacketGetPaymentUrlParams {
    func toDictionaty() -> [AnyHashable: Any] {
        
        return [
            "Amount": Decimal(string: amount) ?? 0.0,
            "FirstName": firstName,
            "LastName": lastName,
            "City": city,
            "Zip": zip,
            "Address": address,
            "Country": country,
            "Email": email,
            "Phone": phone,
            "AssetId": assetId
        ]
    }
}
