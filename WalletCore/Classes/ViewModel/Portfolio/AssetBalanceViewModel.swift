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
            .filterEtheriumBlockchainAsset()
            .mapToEthereumDepositAddress()
            .bind(to: blockchainAddress)
            .disposed(by: disposeBag)

        depositableAssetObservable
            .filterBitcoinBlockchainAsset()
            .mapToBitcoinDepositAddress()
            .bind(to: blockchainAddress)
            .disposed(by: disposeBag)
    }
}

extension Observable where Element == LWAssetModel {
    
    func filterEtheriumBlockchainAsset() -> Observable<LWAssetModel> {
        return filter { $0.blockchainType == BLOCKCHAIN_TYPE_ETHEREUM }
    }
    
    func filterBitcoinBlockchainAsset() -> Observable<LWAssetModel> {
        return filter { $0.blockchainType == BLOCKCHAIN_TYPE_BITCOIN }
    }
    
    func mapToEthereumDepositAddress() -> Observable<String> {
        return
            flatMap { (asset) -> Observable<(Bool, LWAssetModel)> in
                guard asset.blockchainType == BLOCKCHAIN_TYPE_ETHEREUM else {
                    return Observable<(Bool, LWAssetModel)>.empty()
                }
                if asset.blockchainDepositAddress.isNotEmpty {
                    return Observable<(Bool, LWAssetModel)>.just((true, asset))
                }
                return LWEthereumTransactionsManager.shared().rx.createEthereumSign(forAsset: asset)
            }
            .map { (success, asset) in return success ? asset.blockchainDepositAddress : "" }
    }
    
    func mapToBitcoinDepositAddress() -> Observable<String> {
        return
            flatMap { asset -> Observable<ApiResult<LWPacketGetBlockchainAddress>> in
                guard asset.blockchainType == BLOCKCHAIN_TYPE_BITCOIN else {
                    return Observable<ApiResult<LWPacketGetBlockchainAddress>>.empty()
                }
                if asset.blockchainDepositAddress.isNotEmpty {
                    let packet = LWPacketGetBlockchainAddress()
                    packet.assetId = asset.identity
                    packet.address = asset.blockchainDepositAddress
                    return Observable<ApiResult<LWPacketGetBlockchainAddress>>.just(.success(withData: packet))
                }
                return LWRxAuthManager.instance.getBlockchainAddress.request(withParams: asset.identity)
            }
            .filterSuccess()
            .map { $0.address }
    }
    
}
