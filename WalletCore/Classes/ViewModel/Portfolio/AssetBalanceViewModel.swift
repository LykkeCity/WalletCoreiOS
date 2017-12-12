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
        
        asset
            .filter({ return $0.wallet?.asset.blockchainType == BLOCKCHAIN_TYPE_ETHEREUM })
            .flatMap { assetWallet -> Observable<String> in
                guard let asset = assetWallet.wallet?.asset else { return Observable.empty() }
                return Observable.create { observer in
                    LWEthereumTransactionsManager.shared().createEthereumSign(forAsset: asset, completion: { (success) in
                        if success {
                            observer.onNext(asset.blockchainDepositAddress)
                        }
                        observer.onCompleted()
                    })
                    return Disposables.create()
                }
            }
            .bind(to: blockchainAddress)
            .disposed(by: disposeBag)

        asset
            .filter({ return $0.wallet?.asset.blockchainType == BLOCKCHAIN_TYPE_BITCOIN })
            .flatMap {
                return LWRxAuthManager.instance.getBlockchainAddress.request(withParams: $0.cryptoCurrency.identity)
            }
            .filterSuccess()
            .map { $0.address }
            .bind(to: blockchainAddress)
            .disposed(by: disposeBag)
    }
}
