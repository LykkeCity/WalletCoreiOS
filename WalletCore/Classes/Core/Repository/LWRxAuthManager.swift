//
//  LWRxAuthManager.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 6/28/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

public class LWRxAuthManager {
    public static let instance = LWRxAuthManager()
    init() {}
    
    public func triggerSaveCache() -> [Disposable] {

        return [
            allAssets.request()
                .subscribe(),
            baseAsset.request()
                .filterSuccess()
                .subscribe(onNext: {
                    LWCache.instance().baseAssetId = $0.identity
                })
        ]
    }
    
    public lazy var countryCodes        = {LWRxAuthManagerCountryCodes()}()
    public lazy var prevCardPayment     = {LWAuthManagerPacketPrevCardPayment()}()
    public lazy var paymentUrl          = {LWAuthManagerPacketGetPaymentUrl()}()
    public lazy var allAssets           = {LWRxAuthManagerAllAssets()}()
    public lazy var lykkeWallets        = {LWRxAuthManagerLykkeWallets()}()
    public lazy var baseAsset           = {LWRxAuthManagerBaseAsset()}()
    public lazy var mainInfo            = {LWRxAuthManagerMainInfo()}()
    public lazy var emailWalletAddress  = {LWRxAuthManagerEmailWalletAddress()}()
    public lazy var assetPairs          = {LWRxAuthManagerAssetPairs()}()
    public lazy var assetPairRate       = {LWRxAuthManagerAssetPairRate()}()
    public lazy var assetPairRates      = {LWRxAuthManagerAssetPairRates()}()
    public lazy var graphPeriods        = {LWRxAuthManagerGraphPeriods()}()
    public lazy var graphData           = {LWRxAuthManagerGraphData()}()
    public lazy var transactions        = {LWRxAuthManagerTransactions()}()
    public lazy var history             = {LWRxAuthManagerHistory()}()
    public lazy var swiftCredentials    = {LWRxAuthManagerSwiftCredentials()}()
    public lazy var market              = {LWRxMarketManager()}()
    public lazy var getClientCodes      = {LWRxAuthManagerGetClientCodes()}()
    public lazy var postClientCodes     = {LWRxAuthManagerPostClientCodes()}()
    public lazy var encodeMainKey       = {LWRxAuthManagerEncodeMainKey()}()
    public lazy var auth                = {LWRxAuthManagerAuth()}()
    public lazy var emailverification   = {LWRxAuthManagerEmailVerification()}()
    public lazy var pinset              = {LWRxAuthManagerPinSecuritySet()}()
    public lazy var pinget              = {LWRxAuthManagerPinSecurityGet()}()
    public lazy var pinvalidation       = {LWRxAuthManagerEmailVerificationPin()}()
    public lazy var registration        = {LWRxAuthManagerRegistration()}()
    public lazy var settings            = {LWRxAuthManagerPersonalData()}()
    public lazy var setFullName         = {LWRxAuthManagerCleintFullNameSet()}()
    public lazy var getHomeCountry      = {LWRxAuthManagerHomeCountry()}()
    public lazy var setPhoneNumber      = {LWRxAuthManagerPhoneVerificationSet()}()
    public lazy var accountExist        = {LWRxAuthManagerAccountExist()}()
    public lazy var setPhoneNumberPin   = {LWRxAuthManagerPhoneVerificationPin()}()
    public lazy var appSettings         = {LWRxAuthManagerAppSettings()}()
    public lazy var baseAssetSet        = {LWRxAuthManagerBaseAssetSet()}()
    public lazy var pushNotGet          = {LWRxAuthManagerPushNotificationsGet()}()
    public lazy var pushNotSet          = {LWRxAuthManagerPushNotificationsSet()}()
    public lazy var pubKeys             = {LWRxAuthManagerClientKeys()}()
    public lazy var kycForAsset         = {LWRxAuthManagerKYCForAsset()}()
    public lazy var kycDocuments        = {LWRxAuthManagerKYCDocuments()}()
    public lazy var checkPendingActions      = {LWRxAuthManagerCheckPendingActions()}()
    public lazy var offchainTrade       = {LWRxAuthManagerOffchainTrade()}()
    public lazy var offchainFanilazeTransfer = {LWRxAuthManagerOffchainFinalizetransfer()}()
    public lazy var offchainProcessChannel   = {LWRxAuthManagerOffchainProcessChannel()}()
    public lazy var offchainChannelKey       = {LWRxAuthManagerOffchainChannelKey()}()
    public lazy var offchainRequests         = {LWRxAuthManagerOffchainRequests()}()
    public lazy var offchainRequestTransfer  = {LWRxAuthManagerOffchainRequestTransfer()}()
    public lazy var offchainCashOutSwift     = { LWRxAuthManagerOffchainCashOutSwift() }()
    public lazy var cashOutSwift             = { LWRxAuthManagerCashOutSwift() }()
    public lazy var currencyDeposit          = { LWRxAuthManagerCurrencyDeposit() }()
    public lazy var walletMigration          = { LWRxAuthManagerWalletMigration() }()
    public lazy var walletBackupComplete     = { LWRxAuthManagerWalletBackupComplete() }()
}
