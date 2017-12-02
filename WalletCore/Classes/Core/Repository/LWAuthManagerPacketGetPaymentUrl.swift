//
//  LWAuthManagerPacketGetPaymentUrl.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 8/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//
import Foundation
import RxSwift

public class LWAuthManagerPacketGetPaymentUrl:  NSObject{
    
    public typealias Packet = LWPacketGetPaymentUrl
    public typealias Result = ApiResult<LWPacketGetPaymentUrl>
    public typealias RequestParams = (LWPacketGetPaymentUrlParams)
    
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

extension LWAuthManagerPacketGetPaymentUrl: AuthManagerProtocol{
    public func request(withParams params: RequestParams) -> Observable<Result> {
        
        return Observable.create{observer in
            let packet = Packet(observer: observer, params: params)
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