//
//  LWAuthManagerPacketPrevCardPayment.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 8/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWAuthManagerPacketPrevCardPayment: NSObject {

    public typealias Packet = LWPacketPrevCardPayment
    public typealias Result = ApiResult<LWPersonalDataModel>
    public typealias ResultType = LWPersonalDataModel
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

extension LWAuthManagerPacketPrevCardPayment: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketPrevCardPayment {
        return Packet(observer: observer)
    }

    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.lastPaymentPersonalData)
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
