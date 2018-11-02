//
//  BlockchainAddressViewModel.swift
//  WalletCore
//
//  Created by Vladimir Dimov on 24.10.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class BlockchainAddressViewModel {
    
    //IN
    public let asset = PublishSubject<LWAssetModel>()
    
    //OUT
    public let blockchainAddress: Observable<String>
    
    public let assetModel: Observable<LWAssetModel>
    
    public let errors: Observable<[AnyHashable: Any]>
    
    public let loadingViewModel: LoadingViewModel
    
    public init(alertPresenter: AlertPresenter,
                ethTransactionManager: LWEthereumTransactionsManager = LWEthereumTransactionsManager.shared(),
                authManager: LWRxAuthManager = LWRxAuthManager.instance) {
                
        let alertObservable = asset.asObservable()
            .flatMapLatest { asset -> Observable<(confirmation: Bool, asset: LWAssetModel)> in
                if let depositAddress = asset.blockchainDepositAddress, depositAddress.isNotEmpty {
                    return Observable.just( (confirmation: true, asset: asset) )
                }
                
                return  alertPresenter.presentAlert().map { (confirmation: $0, asset: asset) }
            }
            .filter { $0.confirmation }
            .map { $0.asset }
            .shareReplay(1)
        
        let depositableAssetObservable = alertObservable
            .filter { $0.blockchainDeposit }
            .shareReplay(1)
        
        let ethereumAddressRequest = depositableAssetObservable
            .filterEtheriumBlockchainAsset()
            .getEthereumDepositAddress(ethTransactionManager: ethTransactionManager)
            .shareReplay(1)
        
        let ethAddress = ethereumAddressRequest.asObservable()
            .filterSuccess()
            .mapToEthereumDepositAddress()
        
        let bitcoinAddressRequest = depositableAssetObservable
            .filterBitcoinBlockchainAsset()
            .getBitcoinDepositAddress(authManager: authManager)
            .shareReplay(1)
        
        let btcAddress = bitcoinAddressRequest
            .filterSuccess()
            .mapToBitcoinDepositAddress()
        
        blockchainAddress = Observable.merge([ethAddress, btcAddress])
        
        assetModel = asset.asObserver()
        
        errors = Observable.merge(ethereumAddressRequest.filterError(), bitcoinAddressRequest.filterError())
        
        loadingViewModel = LoadingViewModel([ethereumAddressRequest.isLoading(), bitcoinAddressRequest.isLoading()])
    }
}

extension Observable where Element == LWAssetModel {
    
    func filterEtheriumBlockchainAsset() -> Observable<LWAssetModel> {
        return filter { $0.blockchainType == .ethereum }
    }
    
    func filterBitcoinBlockchainAsset() -> Observable<LWAssetModel> {
        return filter { $0.blockchainType == .bitcoint }
    }
    
    func getEthereumDepositAddress(ethTransactionManager: LWEthereumTransactionsManager) -> Observable<ApiResult<LWAssetModel>> {
        return
            flatMap { (asset) -> Observable<ApiResult<LWAssetModel>> in
                return ethTransactionManager.rx.createEthereumSign(forAsset: asset)
            }
    }
    
    func mapToEthereumDepositAddress() -> Observable<String> {
        return
            map { $0.blockchainDepositAddress ?? ""}
    }
    
    func getBitcoinDepositAddress(authManager: LWRxAuthManager) -> Observable<ApiResult<LWPacketGetBlockchainAddress>> {
        return
            flatMap { asset -> Observable<ApiResult<LWPacketGetBlockchainAddress>> in
                return authManager.getBlockchainAddress.request(withParams: asset.identity)
            }
    }
    
}

extension Observable where Element == LWPacketGetBlockchainAddress {
    func mapToBitcoinDepositAddress() -> Observable<String> {
        return
            map { $0.address }
    }
}
