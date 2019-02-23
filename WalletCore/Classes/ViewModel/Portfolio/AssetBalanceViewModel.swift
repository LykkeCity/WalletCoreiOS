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
    
    private let disposeBag = DisposeBag()
    
    public init(asset: Observable<Asset>) {
        assetBalance = asset.mapToCryptoAmount().asDriver(onErrorJustReturn: "")
        assetBalanceInBase = asset.mapToRealAmount().asDriver(onErrorJustReturn: "")
        assetCode = asset.mapToCryptoCode().asDriver(onErrorJustReturn: "")
        baseAssetCode = asset.mapToRealCode().asDriver(onErrorJustReturn: "")
    }
}
