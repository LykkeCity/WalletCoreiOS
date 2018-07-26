//
//  CryptoCurrenciesViewModel.swift
//  WalletCore
//
//  Created by Ivan Stefanovic on 12/22/17.
//

import Foundation
import RxSwift
import RxCocoa

open class CryptoCurrenciesViewModel {
    public var walletsData: Observable<[Variable<LWAddMoneyCryptoCurrencyModel>]>
    public var isLoading: Observable<Bool>
    public init(
        authManager: LWRxAuthManager = LWRxAuthManager.instance
        ) {

        let allWallets = authManager.lykkeWallets.request()

        isLoading = allWallets.isLoading()

        self.walletsData = allWallets
            .filterSuccess()
            .map { data in
                return data.lykkeData.wallets.filter { wallet in
                    guard let spotWallet = wallet as? LWSpotWallet else { return false }

                    return spotWallet.asset.blockchainDepositAddress != nil
                }
                .map { wallet -> Variable<LWAddMoneyCryptoCurrencyModel>? in
                    guard let spotWallet = wallet as? LWSpotWallet else { return nil }

                    let model = LWAddMoneyCryptoCurrencyModel(name: spotWallet.name,
                                                              address: spotWallet.asset.blockchainDepositAddress,
                                                              imageUrl: spotWallet.asset.iconUrl)

                    return Variable(model)
                }
                .flatMap {$0}
        }
    }
}
