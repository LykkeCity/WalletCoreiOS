//
//  LWRxAuthManagerClientKeys.swift
//  Pods
//
//  Created by Nikola Bardarov on 9/4/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerClientKeys: NSObject {
    
    public typealias Packet = LWPacketClientKeys
    public typealias Result = ApiResult<LWPacketClientKeys>
    public typealias RequestParams = (pubKey: String, encodedPrivateKey: String)
    
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

extension LWRxAuthManagerClientKeys: AuthManagerProtocol {
    
    public func request(withParams params: RequestParams) -> Observable<Result> {
        
        return Observable.create{observer in
            let pack = LWPacketClientKeys(observer: observer, pubKey: params.pubKey, encodedPrivateKey: params.encodedPrivateKey)
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

public extension ObservableType where Self.E == ApiResult<LWPacketClientKeys> {
    public func filterSuccess() -> Observable<LWPacketClientKeys> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketClientKeys {
    convenience init(observer: Any, pubKey: String, encodedPrivateKey: String) {
        self.init()
        
        self.pubKey = pubKey
        self.encodedPrivateKey = encodedPrivateKey
        self.observer = observer
    }
}

