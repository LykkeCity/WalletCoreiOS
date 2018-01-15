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
    public typealias ResultType = LWLykkeWalletsData
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

extension ApiResult where Data == LWLykkeWalletsData {
    func asSpotWalletResult(converter: (LWLykkeWalletsData) -> (LWSpotWallet?)) -> ApiResult<LWSpotWallet?>  {
        switch self {
        case .error(let data): return .error(withData: data)
        case .loading: return .loading
        case .notAuthorized: return .notAuthorized
        case .forbidden: return .forbidden
        case .success(let data): return ApiResult<LWSpotWallet?>.success(withData: converter(data))
        }
    }
}

extension LWRxAuthManagerLykkeWallets: AuthManagerProtocol {
    
    //requestLykkeWallets()
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketWallets {
        return Packet(observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: LWPacketWallets) -> ApiResult<LWLykkeWalletsData> {
        return Result.success(withData: packet.data)
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
    
    public func request(byAssetName assetName: String) -> Observable<ApiResult<LWSpotWallet?>> {

        let allAssets = LWRxAuthManager.instance.allAssets.request()
        
        let wallet = allAssets
            .filterSuccess()
            .flatMapLatest{ _ in
                return self.request().map{ result in
                    result.asSpotWalletResult{ data in
                        (data.lykkeData.wallets ?? [])
                            .map{ $0 as! LWSpotWallet }
                            .first{ $0.name == assetName }
                    }
                }
            }
            .shareReplay(1)
        
        let errors = Observable
            .merge([
                allAssets.filterError(),
                wallet.filterError()
            ])
            .map{ ApiResult<LWSpotWallet?>.error(withData: $0) }
        
        let walletResult = wallet
            .filterSuccess()
            .map{ ApiResult<LWSpotWallet?>.success(withData: $0) }
        
        return Observable
            .merge(errors, walletResult)
            .startWith(ApiResult<LWSpotWallet?>.loading)
    }
    
    public func request(byAssetId assetId: String) -> Observable<ApiResult<LWSpotWallet?>> {
        return request().map{result in
            result.asSpotWalletResult{ data in
                (data.lykkeData.wallets ?? [])
                    .map{ $0 as! LWSpotWallet }
                    .first{ $0.identity == assetId }
            }
        }
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
    
    public func filterError() -> Observable<[AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
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
