//
//  LWRxAuthManagerKYCDocuments.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/20/17.
//  Copyright © 2017 Lykke. All rights reserved.
//
import Foundation
import RxSwift

public class LWRxAuthManagerKYCDocuments : NSObject{
    
    public typealias Packet = LWPacketKYCDocuments
    public typealias Result = ApiResult<LWKYCDocumentsModel>
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

extension LWRxAuthManagerKYCDocuments: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketKYCDocuments {
        return Packet(observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.documentsStatuses)
    }
}

public extension ObservableType where Self.E == ApiResult<LWKYCDocumentsModel> {
    public func filterSuccess() -> Observable<LWKYCDocumentsModel> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable<[AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func filterForbidden() -> Observable<Void> {
        return filter{$0.isForbidden}.map{_ in Void()}
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
