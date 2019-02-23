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
    public typealias ResultType = LWPacketGetPaymentUrl
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
    public func createPacket(withObserver observer: Any, params: (LWPacketGetPaymentUrlParams)) -> LWPacketGetPaymentUrl {
        return Packet(observer: observer, params: params)
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
