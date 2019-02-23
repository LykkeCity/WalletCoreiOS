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

public protocol LWRxAuthManagerProtocol {
    var baseAsset: LWRxAuthManagerBaseAssetProtocol { get }
    var baseAssets: LWRxAuthManagerBaseAssetsProtocol { get }
    var allAssets: LWRxAuthManagerAllAssetsProtocol { get }
    var assetPairRates: LWRxAuthManagerAssetPairRatesProtocol { get }
    var assetPairs: LWRxAuthManagerAssetPairsProtocol { get }
}

public class LWRxAuthManager: LWRxAuthManagerProtocol {
    public static let instance = LWRxAuthManager()
    init() {}
    
    public func triggerSaveCache(baseAssetId: String = "USD") -> [Disposable] {

        return [
            allAssets.request()
                .subscribe(),
            baseAssetSet
                .request(withParams: baseAssetId)
                .filterSuccess()
                .flatMap{[baseAsset] _ in
                    baseAsset.request().filterSuccess()
                }
                .subscribe(onNext: {
                    LWCache.instance().baseAssetId = $0.identity
                })
        ]
    }
    
    public lazy var allAssets: LWRxAuthManagerAllAssetsProtocol             = { LWRxAuthManagerAllAssets() }()
    public lazy var assetPairRates: LWRxAuthManagerAssetPairRatesProtocol   = { LWRxAuthManagerAssetPairRates() }()
    public lazy var baseAsset: LWRxAuthManagerBaseAssetProtocol             = { LWRxAuthManagerBaseAsset() }()
    public lazy var baseAssets: LWRxAuthManagerBaseAssetsProtocol           = { LWRxAuthManagerBaseAssets() }()
    public lazy var assetPairs: LWRxAuthManagerAssetPairsProtocol           = {LWRxAuthManagerAssetPairs()}()
    
    public lazy var countryCodes        = {LWRxAuthManagerCountryCodes()}()
    public lazy var prevCardPayment     = {LWAuthManagerPacketPrevCardPayment()}()
    public lazy var paymentUrl          = {LWAuthManagerPacketGetPaymentUrl()}()
    public lazy var lykkeWallets        = {LWRxAuthManagerLykkeWallets()}()
    public lazy var emailWalletAddress  = {LWRxAuthManagerEmailWalletAddress()}()
    
    public lazy var assetPairRate       = {LWRxAuthManagerAssetPairRate()}()
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
    public lazy var emailverificationSms   = {LWRxAuthManagerEmailVerificationSMS()}()
    public lazy var pinset              = {LWRxAuthManagerPinSecuritySet()}()
    public lazy var pinget              = {LWRxAuthManagerPinSecurityGet()}()
    public lazy var pinvalidation       = {LWRxAuthManagerEmailVerificationPin()}()
    public lazy var registration        = {LWRxAuthManagerRegistration()}()
    public lazy var ownershipMessage    = { LWRxAuthManagerOwnershipMessage() }()
    public lazy var settings            = {LWRxAuthManagerPersonalData()}()
    public lazy var setFullName         = {LWRxAuthManagerCleintFullNameSet()}()
    public lazy var getHomeCountry      = {LWRxAuthManagerHomeCountry()}()
    public lazy var setPhoneNumber      = {LWRxAuthManagerPhoneVerificationSet()}()
    public lazy var phoneCodeSend       = {LWRxAuthManagerPhoneCodeSend()}()
    public lazy var phoneCodeVerify     = {LWRxAuthManagerPhoneCodeVerify()}()
    public lazy var emailCodeSend       = {LWRxAuthManagerEmailCodeSend()}()
    public lazy var emailCodeVerify     = {LWRxAuthManagerEmailCodeVerify()}()
    public lazy var getEncodedPrivateKey = {LWRxAuthManagerGetEncodedPrivateKey()}()
    public lazy var accountExist        = {LWRxAuthManagerAccountExist()}()
    public lazy var setPhoneNumberPin   = {LWRxAuthManagerPhoneVerificationPin()}()
    public lazy var appSettings         = {LWRxAuthManagerAppSettings()}()
    public lazy var baseAssetSet        = {LWRxAuthManagerBaseAssetSet()}()
    public lazy var pushNotGet          = {LWRxAuthManagerPushNotificationsGet()}()
    public lazy var pushNotSet          = {LWRxAuthManagerPushNotificationsSet()}()
    public lazy var pubKeys             = {LWRxAuthManagerClientKeys()}()
    public lazy var kycForAsset         = {LWRxAuthManagerKYCForAsset()}()
    public lazy var kycStatusGet        = {LWRxAuthManagerKYCStatusGet()}()
    public lazy var kycDocuments        = {LWRxAuthManagerKYCDocuments()}()
    public lazy var checkPendingActions      = {LWRxAuthManagerCheckPendingActions()}()
    public lazy var offchainTrade            = {LWRxAuthManagerOffchainTrade()}()
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
    public lazy var getBlockchainAddress     = { LWRxAuthManagerGetBlockchainAddress() }()
    public lazy var sendBlockchainEmail      = { LWRxAuthManagerSendBlockchainEmail() }()
    public lazy var cashOut                  = { LWRxAuthManagerCashOut() }()
    public lazy var applicationInfo          = { LWRxAuthManagerApplicationInfo() }()
    public lazy var settingSignOrder         = { LWRxAuthManagerSettingSignOrder() }()
    public lazy var marketCap                = { LWRxAuthManagerMarketCap() }()
    public lazy var assetDisclaimers         = { LWRxAuthManagerAssetDisclaimersGet() }()
    public lazy var assetDisclaimerAccept    = { LWRxAuthManagerAssetDisclaimersApprove() }()
    public lazy var assetDisclaimerDecline   = { LWRxAuthManagerAssetDisclaimersDecline() }()
    public lazy var recoverySmsConfirmation  = { LWRxAuthManagerRecoverySmsConfirmation() }()
    public lazy var changePinAndPassword     = { LWRxAuthManagerChangePinAndPassword() }()
}
