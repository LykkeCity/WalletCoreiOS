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
    ) -> Observable<ApiResult<Void>> {
        if cache.flagOffchainRequests {
            return Observable.never()
        }
        else {
            let body = LWPacketCashOutSwift.Body(amount: data.amount,
                                                 asset: data.asset.identity,
                                                 bankName: data.bankName,
                                                 iban: data.iban,
                                                 bic: data.bic,
                                                 accountHolder: data.accountHolder,
                                                 accountHolderAddress: data.accountHolderAddress)
            return authManager.cashOutSwift.request(withData: body)
        }
    }

}
