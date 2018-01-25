//
//  AssetsFilterViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 25.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class AssetsFilterViewModel {
    
    public enum FilterType {
        case all
        case crypto
        case fiat
    }
    
    /// Filtered assets according to the last filter
    public let filteredAssets: Driver<[Variable<Asset>]>
    
    /// On each filter event filteredAssets will be updated accordingly
    public let filter = Variable<FilterType>(.all)
    
    public init(assetsToFilter: Observable<[Variable<Asset>]>) {
        filteredAssets = Observable
            .combineLatest(assetsToFilter, filter.asObservable())
            .filterByType()
            .asDriver(onErrorJustReturn: [])
    }
}

fileprivate extension ObservableType where Self.E == ([Variable<Asset>], AssetsFilterViewModel.FilterType) {
    func filterByType() -> Observable<[Variable<Asset>]> {
        return map{ assets, filter -> [Variable<Asset>] in
            
            if filter.isAll { return assets }
            
            return assets.filter{ asset in
                guard let isFiatAsset = asset.value.wallet?.asset?.isFiat else { return false }
                return filter.isFiat == isFiatAsset
            }
        }
    }
}

public extension AssetsFilterViewModel.FilterType {
    var isFiat: Bool {
        guard case .fiat = self else { return false }
        return true
    }
    
    var isAll: Bool {
        guard case .all = self else { return false }
        return true
    }
    
    var isCrypto: Bool {
        guard case .crypto = self else { return false }
        return true
    }
}
