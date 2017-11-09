//
//  LWRxAuthManagerKYCForAsset.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/20/17.
//  Copyright © 2017 Lykke. All rights reserved.
//
import Foundation
import RxSwift

public class LWRxAuthManagerKYCForAsset : NSObject{
    
    public typealias Packet = LWPacketKYCForAsset
    public typealias Result = ApiResult<LWPacketKYCForAsset>
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

extension LWRxAuthManagerKYCForAsset: AuthManagerProtocol{
    
    public func request(withParams params: RequestParams) -> Observable<Result> {
        return Observable.create{observer in
            let packet = Packet(observer: observer, assetId: params)
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

public extension ObservableType where Self.E == ApiResult<LWPacketKYCForAsset> {
    public func filterSuccess() -> Observable<LWPacketKYCForAsset> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketKYCForAsset {
    convenience init(observer: Any, assetId: String) {
        self.init()
        self.observer = observer
        self.assetId = assetId
    }
}
