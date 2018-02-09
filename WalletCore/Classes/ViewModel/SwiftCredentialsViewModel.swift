//
//  SwiftCredentialsViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class SwiftCredentialsViewModel {
    public let bic: Driver<String>
    public let accountNumber: Driver<String>
    public let accountName: Driver<String>
    public let purposeOfPayment: Driver<String>
    public let bankAddress: Driver<String>
    public let companyAddress: Driver<String>
    
    public let loadingViewModel: LoadingViewModel
    public let errors: Driver<[AnyHashable: Any]>
    
    public init(credentialsForAsset asset: LWAssetModel,
                authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let swiftCredentials = authManager.swiftCredentials
            .request(withParams: asset.identity)
            .shareReplay(1)
        
        loadingViewModel = LoadingViewModel([
            swiftCredentials.isLoading()
        ])
        
        errors = swiftCredentials
            .filterError()
            .asDriver(onErrorJustReturn: [:])
        
        let swiftCredentialsModel = swiftCredentials.filterSuccess()
        
        bic                 = swiftCredentialsModel.mapToBIC()
        accountNumber       = swiftCredentialsModel.mapToAccountNumber()
        accountName         = swiftCredentialsModel.mapToAccountName()
        purposeOfPayment    = swiftCredentialsModel.mapToPurposeOfPayment()
        bankAddress         = swiftCredentialsModel.mapToBankAddress()
        companyAddress      = swiftCredentialsModel.mapToCompanyAddress()
    }
}

extension ObservableType where Self.E == LWSwiftCredentialsModel {
    func mapToBIC() -> Driver<String> {
        return map{ $0.bic }.asDriver(onErrorJustReturn: "")
    }
    
    func mapToAccountNumber() -> Driver<String> {
        return map{ $0.accountNumber }.asDriver(onErrorJustReturn: "")
    }
    
    func mapToAccountName() -> Driver<String> {
        return map{ $0.accountName }.asDriver(onErrorJustReturn: "")
    }
    
    func mapToPurposeOfPayment() -> Driver<String> {
        return
            map{ $0.purposeOfPayment.replacingOccurrences(of: "{1}", with: "") }
            .map{ $0.replacingOccurrences(of: "{0}", with: "") }
            .asDriver(onErrorJustReturn: "")
    }
    
    func mapToBankAddress() -> Driver<String> {
        return map{ $0.bankAddress }.asDriver(onErrorJustReturn: "")
    }
    
    func mapToCompanyAddress() -> Driver<String> {
        return map{ $0.companyAddress }.asDriver(onErrorJustReturn: "")
    }
    
}
