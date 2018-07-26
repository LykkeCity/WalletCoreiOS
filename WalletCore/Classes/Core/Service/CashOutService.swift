//
//  CashOutService.swift
//  WalletCore
//
//  Created by Nacho Nachev on 1.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class CashOutService {

    public struct CashOutData {
        public let amount: Decimal
        public let asset: LWAssetModel
        public let bankName: String
        public let iban: String
        public let bic: String
        public let accountHolder: String
        public let accountHolderAddress: String
        public let accountHolderCountry: String
        public let accountHolderCountryCode: String
        public let accountHolderZipCode: String
        public let accountHolderCity: String
        public let reason: String
        public let notes: String
    }

    private let authManager: LWRxAuthManager
    private let cache: LWCache
    private let offchainService: OffchainService

    public static let instance: CashOutService = {
        return CashOutService(authManager: LWRxAuthManager.instance,
                              cache: LWCache.instance(),
                              offchainService: OffchainService.instance)
    }()

    private init(
        authManager: LWRxAuthManager,
        cache: LWCache,
        offchainService: OffchainService
    ) {
        self.authManager = authManager
        self.cache = cache
        self.offchainService = offchainService
    }

    public func swiftCashOut(withData data: CashOutData
    ) -> Observable<ApiResult<LWModelCashOutSwiftResult>> {
        return offchainService.cashOutSwift(amount: data.amount,
                                            fromAsset: data.asset,
                                            toBank: data.bankName,
                                            iban: data.iban,
                                            bic: data.bic,
                                            accountHolder: data.accountHolder,
                                            accountHolderAddress: data.accountHolderAddress,
                                            accountHolderCountry: data.accountHolderCountry,
                                            accountHolderCountryCode: data.accountHolderCountryCode,
                                            accountHolderZipCode: data.accountHolderZipCode,
                                            accountHolderCity: data.accountHolderCity)
            .mapToCashOutSwiftResult(withData: data)
    }

    public func cashout(to address: String, assetId: String, amount: Decimal) -> Observable<ApiResult<Bool>> {
        guard let asset = LWCache.asset(byId: assetId) else {
            return Observable.just(ApiResult.error(withData: ["Message": "Please specify asset."]))
        }

        return Observable.create { (observer) -> Disposable in
            if asset.isErc20 || asset.isTrusted {
                HotWalletNetworkClient.cachout(to: address,
                                               assetId: assetId,
                                               volume: amount as NSDecimalNumber,
                                               completion: { success in
                                                observer.onNext(.success(withData: success))
                                                observer.onCompleted()
                })
            } else if asset.blockchainType == .ethereum {
                LWEthereumTransactionsManager.shared().requestCashout(forAsset: asset,
                                                                      volume: amount as NSDecimalNumber,
                                                                      addressTo: address,
                                                                      completion: { (data) in
                                                                        observer.onNext(.success(withData: data != nil))
                                                                        observer.onCompleted()
                })
            } else {
                LWOffchainTransactionsManager.shared().requestCashOut(amount as NSDecimalNumber,
                                                                      assetId: assetId,
                                                                      multiSig: address,
                                                                      completion: { data in
                                                                        observer.onNext(.success(withData: data != nil))
                                                                        observer.onCompleted()
                })
            }

            return Disposables.create {}
        }
            .startWith(.loading)
            .shareReplay(1)
    }

}

fileprivate extension Observable where Element == ApiResult<Void> {
    func mapToCashOutSwiftResult(withData data: CashOutService.CashOutData) -> Observable<ApiResult<LWModelCashOutSwiftResult>> {
        return map { result in
            switch result {
            case .loading:
                return .loading
            case .success:
                let result = LWModelCashOutSwiftResult(data: data)
                return .success(withData: result)
            case .error(let errorData):
                return .error(withData: errorData)
            case .notAuthorized:
                return .notAuthorized
            case .forbidden:
                return .forbidden
            }
        }
    }
}

fileprivate extension Observable where Element == ApiResult<LWModelOffchainResult> {
    func mapToCashOutSwiftResult(withData data: CashOutService.CashOutData) -> Observable<ApiResult<LWModelCashOutSwiftResult>> {
        return map { result in
            switch result {
            case .loading:
                return .loading
            case .success:
                let result = LWModelCashOutSwiftResult(data: data)
                return .success(withData: result)
            case .error(let errorData):
                return .error(withData: errorData)
            case .notAuthorized:
                return .notAuthorized
            case .forbidden:
                return .forbidden
            }
        }
    }
}

fileprivate extension LWModelCashOutSwiftResult {

    init(data: CashOutService.CashOutData) {
        self.init(amount: data.amount.convertAsCurrencyStrip(asset: data.asset),
                  asset: data.asset.identity,
                  bankName: data.bankName,
                  iban: data.iban,
                  bic: data.bic,
                  accountHolder: data.accountHolder,
                  accountHolderCountry: data.accountHolderCountry,
                  accountHolderCountryCode: data.accountHolderCountryCode,
                  accountHolderZipCode: data.accountHolderZipCode,
                  accountHolderCity: data.accountHolderCity)
    }

}
