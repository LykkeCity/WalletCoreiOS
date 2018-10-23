//
//  AssetBalanceViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 15.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class AssetBalanceViewModel {
    
    public let assetBalance: Driver<String>
    public let assetCode: Driver<String>
    public let assetBalanceInBase: Driver<String>
    public let baseAssetCode: Driver<String>
    public let blockchainAddress = Variable("")
    
    private let disposeBag = DisposeBag()
    
    public init(asset: Observable<Asset>) {
        assetBalance = asset.mapToCryptoAmount().asDriver(onErrorJustReturn: "")
        assetBalanceInBase = asset.mapToRealAmount().asDriver(onErrorJustReturn: "")
        assetCode = asset.mapToCryptoCode().asDriver(onErrorJustReturn: "")
        baseAssetCode = asset.mapToRealCode().asDriver(onErrorJustReturn: "")
        
        let depositableAssetObservable = asset
            .map { $0.wallet?.asset }
            .filterNil()
            .filter { $0.blockchainDeposit }
            .shareReplay(1)
        
        depositableAssetObservable
            .distinctUntilChanged()
            .filterEtheriumBlockchainAsset()
            .mapToEthereumDepositAddress()
            .bind(to: blockchainAddress)
            .disposed(by: disposeBag)

        depositableAssetObservable
            .distinctUntilChanged()
            .filterBitcoinBlockchainAsset()
            .mapToBitcoinDepositAddress()
            .bind(to: blockchainAddress)
            .disposed(by: disposeBag)
    }
}

extension Observable where Element == LWAssetModel {
    
    func filterEtheriumBlockchainAsset() -> Observable<LWAssetModel> {
        return filter { $0.blockchainType == .ethereum }
    }
    
    func filterBitcoinBlockchainAsset() -> Observable<LWAssetModel> {
        return filter { $0.blockchainType == .bitcoint }
    }
    
    func mapToEthereumDepositAddress() -> Observable<String> {
        return
            flatMap { (asset) -> Observable<(Bool, LWAssetModel)> in
                guard asset.blockchainType == .ethereum else {
                    return Observable<(Bool, LWAssetModel)>.empty()
                }
                return LWEthereumTransactionsManager.shared().rx.createEthereumSign(forAsset: asset)
            }
            .map { (success, asset) in return success ? asset.blockchainDepositAddress : "" }
    }
    
    func mapToBitcoinDepositAddress() -> Observable<String> {
        return
            flatMap { asset -> Observable<ApiResult<LWPacketGetBlockchainAddress>> in
                guard asset.blockchainType == .bitcoint else {
                    return Observable<ApiResult<LWPacketGetBlockchainAddress>>.empty()
                }
                return LWRxAuthManager.instance.getBlockchainAddress.request(withParams: asset.identity)
            }
            .filterSuccess()
            .map { packet in
                (LWCache.instance().allAssets as? [LWAssetModel] ?? []).filter { $0.identity == packet.assetId }.first?.blockchainDepositAddress = packet.address
                return packet.address
            }
    }
    
}
