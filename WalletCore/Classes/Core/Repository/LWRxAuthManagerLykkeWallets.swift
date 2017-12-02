//
//  LWRxAuthManagerLykkeWallets.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerLykkeWallets: NSObject{
    
    public typealias Packet = LWPacketWallets
    public typealias Result = ApiResult<LWLykkeWalletsData>
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

extension LWRxAuthManagerLykkeWallets: AuthManagerProtocol {
    
    //requestLykkeWallets()
    public func request(withParams params:RequestParams = Void()) -> Observable<Result> {
        return Observable.create{observer in
           
            let pack = Packet(observer: observer)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    public func requestNonEmptyWallets() -> Observable<ApiResultList<LWSpotWallet>> {
        return request()
            .map{result in
                switch result {
                    case .error(let data): return .error(withData: data)
                    case .loading: return .loading
                    case .notAuthorized: return .notAuthorized
                    case .forbidden: return .forbidden
                    case .success(let data): return .success(withData:
                        (data.lykkeData.wallets ?? [])
                            .map{ $0 as! LWSpotWallet }
                            .filter{ $0.balance.doubleValue > 0.0 }
                    )
                }
            }
    }
    
    public func request(byAssetId assetId: String) -> Observable<ApiResult<LWSpotWallet?>> {
        return request()
            .map{result in
                switch result {
                case .error(let data): return .error(withData: data)
                case .loading: return .loading
                case .notAuthorized: return .notAuthorized
                case .forbidden: return .forbidden
                case .success(let data): return .success(withData:
                    (data.lykkeData.wallets ?? [])
                        .map{ $0 as! LWSpotWallet }
                        .first{ $0.identity == assetId }
                    )
                }
        }
    }
    
    func getErrorResult(fromPacket packet: Packet) -> Result {
        return Result.error(withData: packet.errors)
    }
    
    func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.data)
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return Result.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return Result.notAuthorized
    }
}

public extension ObservableType where Self.E == ApiResult<LWSpotWallet?> {
    public func filterSuccess() -> Observable<LWSpotWallet?> {
        return filter{ $0.isSuccess }.map{
            guard let wallet = $0.getSuccess() else {
                return nil
            }
            
            return wallet
        }
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}


public extension ObservableType where Self.E == ApiResultList<LWSpotWallet> {
    public func filterSuccess() -> Observable<[LWSpotWallet]> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

public extension ObservableType where Self.E == ApiResult<LWLykkeWalletsData> {
    public func filterSuccess() -> Observable<LWLykkeWalletsData> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
    
    public func filterError() -> Observable<[AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
}
