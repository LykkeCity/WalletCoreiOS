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
    public let trigger = PublishSubject<Void>()
    
    //OUT
    public let blockchainAddress: Observable<String>
    
    public let assetModel: Observable<LWAssetModel>
    
    public let isAvailable: Observable<Bool>
    
    public init(asset: Observable<LWAssetModel>,
                alertPresenter: AlertPresenter,
                ethTransactionManager: LWEthereumTransactionsManager = LWEthereumTransactionsManager.shared(),
                authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let alertObservable = trigger
            .withLatestFrom(asset.asObservable())
            .flatMap { asset -> Observable<(confirmation: Bool, asset: LWAssetModel)> in
                if let _ = asset.blockchainDepositAddress {
                    return Observable.just( (confirmation: true, asset: asset) )
                } else {
                   return  alertPresenter.presentAlert().map { (confirmation: $0, asset: asset) }
                }
            }
            .filter { $0.confirmation }
            .map { $0.asset }
            .shareReplay(1)
        
        let depositableAssetObservable = alertObservable
            .withLatestFrom(asset.asObservable())
            .filter { $0.blockchainDeposit }
            .shareReplay(1)
        
        let ethAddress = depositableAssetObservable
            .distinctUntilChanged()
            .filterEtheriumBlockchainAsset()
            .mapToEthereumDepositAddress(ethTransactionManager: ethTransactionManager)
            .shareReplay(1)

        
        let btcAddress = depositableAssetObservable
            .distinctUntilChanged()
            .filterBitcoinBlockchainAsset()
            .mapToBitcoinDepositAddress(authManager: authManager)
            .shareReplay(1)

        blockchainAddress = Observable.merge([ethAddress, btcAddress])

        assetModel = Observable.combineLatest(asset.asObservable(), self.blockchainAddress.asObservable())
            .map { $0.blockchainDepositAddress = $1
                return $0
            }
        
        isAvailable = asset
            .map { $0.blockchainDeposit }
    }
}

extension Observable where Element == LWAssetModel {
    
    func filterEtheriumBlockchainAsset() -> Observable<LWAssetModel> {
        return filter { $0.blockchainType == .ethereum }
    }
    
    func filterBitcoinBlockchainAsset() -> Observable<LWAssetModel> {
        return filter { $0.blockchainType == .bitcoint }
    }
    
    func mapToEthereumDepositAddress(ethTransactionManager: LWEthereumTransactionsManager) -> Observable<String> {
        return
            flatMap { (asset) -> Observable<(Bool, LWAssetModel)> in
                guard asset.blockchainType == .ethereum else {
                    return Observable<(Bool, LWAssetModel)>.empty()
                }
                return ethTransactionManager.rx.createEthereumSign(forAsset: asset)
                }
                .map { (success, asset) in return success ? asset.blockchainDepositAddress : "" }
    }
    
    func mapToBitcoinDepositAddress(authManager: LWRxAuthManager) -> Observable<String> {
        return
            flatMap { asset -> Observable<ApiResult<LWPacketGetBlockchainAddress>> in
                guard asset.blockchainType == .bitcoint else {
                    return Observable<ApiResult<LWPacketGetBlockchainAddress>>.empty()
                }
                return authManager.getBlockchainAddress.request(withParams: asset.identity)
                }
                .filterSuccess()
                .map { packet in
                    //Cache should be inside the repository layer of the application
                    (LWCache.instance().allAssets as? [LWAssetModel] ?? []).filter { $0.identity == packet.assetId }.first?.blockchainDepositAddress = packet.address
                    return packet.address
        }
    }
    
}
