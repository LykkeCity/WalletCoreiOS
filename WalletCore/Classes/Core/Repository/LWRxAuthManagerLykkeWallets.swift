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
    fileprivate let addressReceivedTrigger = PublishSubject<Void>()
    
    override init() {
        super.init()
        subscribe(observer: self, succcess: #selector(self.successSelector(_:)), error: #selector(self.errorSelector(_:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(onAddressCreated(_:)), name: .blockchainAddressReceived, object: nil)
    }
    
    deinit {
        unsubscribe(observer: self)
        NotificationCenter.default.removeObserver(self, name: .blockchainAddressReceived, object: nil)
    }
    
    @objc func onAddressCreated(_ notification: NSNotification) {
        addressReceivedTrigger.onNext(())
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
    
    public func request() -> Observable<Result> {
        return self.request(withParams: ())
    }
    
    public func request(withParams params: RequestParams) -> Observable<Result> {
        
        let receivedData = self.addressReceivedTrigger.asObservable()
            .flatMapLatest { [weak self] _ in
                self?.defaultRequestImplementation(with: params) ?? Observable.never()
            }
        
        return Observable.merge(self.defaultRequestImplementation(with: params), receivedData)
    }
    
    public func getSuccessResult(fromPacket packet: LWPacketWallets) -> ApiResult<LWLykkeWalletsData> {
        return Result.success(withData: packet.data)
    }
    
    public func requestNonEmptyWallets() -> Observable<ApiResult<[LWSpotWallet]>> {
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
