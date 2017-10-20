//
//  LWAuthManager.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 09.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthManager.h"
#import "LWPacketAccountExist.h"
#import "LWPacketAuthentication.h"
#import "LWPacketRegistration.h"
#import "LWPacketRegistrationGet.h"
#import "LWPacketCheckDocumentsToUpload.h"
#import "LWPacketKYCSendDocument.h"
#import "LWPacketKYCSendDocumentBin.h"
#import "LWPacketKYCStatusGet.h"
#import "LWPacketKYCStatusSet.h"
#import "LWPacketPinSecurityGet.h"
#import "LWPacketPinSecuritySet.h"
#import "LWPacketRestrictedCountries.h"
#import "LWPacketPersonalData.h"
#import "LWPacketLog.h"
#import "LWPacketBankCards.h"
#import "LWPacketBaseAssets.h"
#import "LWPacketBaseAssetGet.h"
#import "LWPacketBaseAssetSet.h"
#import "LWPacketAssetPair.h"
#import "LWPacketAssetPairs.h"
#import "LWPacketAssetPairRate.h"
#import "LWPacketAssetPairRates.h"
#import "LWPacketAppSettings.h"
#import "LWPacketAssetsDescriptions.h"
#import "LWPacketBuySellAsset.h"
#import "LWPacketSettingSignOrder.h"
#import "LWPacketBlockchainTransaction.h"
#import "LWPacketBlockchainCashTransaction.h"
#import "LWPacketBlockchainExchangeTransaction.h"
#import "LWPacketBlockchainTransferTransaction.h"
#import "LWPacketTransactions.h"
#import "LWPacketMarketOrder.h"
#import "LWPacketSendBlockchainEmail.h"
#import "LWPacketExchangeInfoGet.h"
#import "LWPacketDicts.h"
#import "LWPacketCashOut.h"
#import "LWPacketTransfer.h"
#import "LWPacketEmailVerificationGet.h"
#import "LWPacketEmailVerificationSet.h"
#import "LWPacketPhoneVerificationGet.h"
#import "LWPacketPhoneVerificationSet.h"
#import "LWPacketClientFullNameSet.h"
#import "LWPacketCountryCodes.h"
#import "LWPacketGraphPeriods.h"
#import "LWPacketGraphData.h"
#import "LWPacketCurrencyDeposit.h"
#import "LWPacketCurrencyWithdraw.h"
#import "LWPacketApplicationInfo.h"
#import "LWPacketBitcoinAddressValidation.h"
#import "LWPacketSetRevertedPair.h"
#import "LWPacketAllAssets.h"
#import "LWPacketLastBaseAssets.h"
#import "LWPacketKYCForAsset.h"
#import "LWPacketGetRefundAddress.h"
#import "LWPacketSetRefundAddress.h"
#import "LWPacketPushSettingsGet.h"
#import "LWPacketPushSettingsSet.h"
#import "LWPacketEncodedPrivateKey.h"
#import "LWPacketClientKeys.h"
#import "LWPacketGetPaymentUrl.h"
#import "LWPacketPrevCardPayment.h"
#import "LWPacketGetHistory.h"
#import "LWPrivateKeyOwnershipMessage.h"
#import "LWPacketRecoverySMSConfirmation.h"
#import "LWPacketChangePINAndPassword.h"
#import "LWPacketAllAssetPairsRates.h"
#import "LWPacketMyLykkeInfo.h"
#import "LWPacketAllAssetPairs.h"
#import "LWPacketGetNews.h"
#import "LWPacketMyLykkeCashInEmail.h"
#import "LWPacketSwiftCredentials.h"
#import "LWPacketSwiftCredential.h"
#import "LWPacketGetEthereumAddress.h"
#import "LWPacketLykkeSettings.h"
#import "LWPacketEmailHint.h"
#import "LWPacketSaveBackupState.h"
#import "LWPacketVoiceCall.h"
#import "LWPacketWalletMigration.h"
#import "LWPacketPasswordHashSet.h"
#import "LWPacketOrderBook.h"
#import "LWPacketKYCDocuments.h"
#import "LWPacketCategories.h"
#import "LWPacketGetPendingTransactions.h"
#import "LWPacketSendSignedTransaction.h"
#import "LWPacketGetEthereumContract.h"
#import "LWPacketEmailPrivateWalletAddress.h"
#import "LWPacketMarketConverter.h"
#import "LWPacketSolarCoinEmail.h"
#import "LWPacketGetIssuers.h"
#import "LWPacketGetBlockchainAddress.h"
#import "LWPacketSettleForwardWithdraw.h"
#import "LWPacketCheckIsUSAUser.h"
#import "LWPacketSetUSAUser.h"
#import "LWPacketCheckPendingActions.h"
#import "LWPacketGetUnsignedSPOTTransactions.h"
#import "LWPacketSendSignedSPOTTransactions.h"
#import "LWPacketGetMarginTermsStatus.h"
#import "LWPacketSetMarginTermsStatus.h"

#import "LWPacketGetMainScreenInfo.h"
#import "LWPacketMarginDepositWithdraw.h"
#import "LWPacketResetDemoMarginAccount.h"

#import "LWPacketLogout.h"
#import "LWPacketGetCFDWatchLists.h"
#import "LWPacketGetSpotWatchLists.h"
#import "LWPacketSaveWatchList.h"
#import "LWPacketDeleteWatchList.h"

#import "LWLykkeWalletsData.h"
#import "LWBankCardsAdd.h"
#import "LWPacketWallets.h"
#import "LWKeychainManager.h"
#import "LWAssetDealModel.h"
#import "LWPersonalDataModel.h"
#import "LWAssetBlockchainModel.h"
#import "LWExchangeInfoModel.h"
#import "LWSwiftCredentialsModel.h"


#import "LWUtils.h"




@interface LWAuthManager () {
    
}

#pragma mark - Observing

- (void)observeGDXNetAdapterDidReceiveResponseNotification:(NSNotification *)notification;
- (void)observeGDXNetAdapterDidFailRequestNotification:(NSNotification *)notification;

@end


@implementation LWAuthManager

#pragma mark - Common

+ (LWAuthManager*)instance {
    static LWAuthManager *sharedObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedObject = [[self alloc] init];

        if (sharedObject) {
            [sharedObject subscribe:kNotificationGDXNetAdapterDidReceiveResponse
                          selector:@selector(observeGDXNetAdapterDidReceiveResponseNotification:)];
            [sharedObject subscribe:kNotificationGDXNetAdapterDidFailRequest
                          selector:@selector(observeGDXNetAdapterDidFailRequestNotification:)];
        }
    });
    
    return sharedObject;
}

+ (LWAuthManager*)newInstance {
//    return [LWAuthManager instance];
    
    LWAuthManager* authManager = [[self alloc] init];
    
    if (authManager) {
        [authManager subscribe:kNotificationGDXNetAdapterDidReceiveResponse
                      selector:@selector(observeGDXNetAdapterDidReceiveResponseNotification:)];
        [authManager subscribe:kNotificationGDXNetAdapterDidFailRequest
                      selector:@selector(observeGDXNetAdapterDidFailRequestNotification:)];
    }
    
    return authManager;
}

- (void)requestEmailValidation:(NSString *)email {
    LWPacketAccountExist *pack = [LWPacketAccountExist new];
    pack.email = email;
    
    [self sendPacket:pack];
}

- (void)requestAuthentication:(LWAuthenticationData *)data {
    LWPacketAuthentication *pack = [LWPacketAuthentication new];
    pack.authenticationData = data;
    
    [self sendPacket:pack];
}

- (void)requestRegistration:(LWRegistrationData *)data {
    LWPacketRegistration *pack = [LWPacketRegistration new];
    pack.registrationData = data;
    
    [self sendPacket:pack];
}

- (void)requestRegistrationGet {
    LWPacketRegistrationGet *pack = [LWPacketRegistrationGet new];
    
    [self sendPacket:pack];
}

- (void)requestDocumentsToUpload {
    LWPacketCheckDocumentsToUpload *pack = [LWPacketCheckDocumentsToUpload new];

    [self sendPacket:pack];
}

- (void)requestSendDocument:(KYCDocumentType)docType image:(UIImage *)image {
    LWPacketKYCSendDocument *pack = [LWPacketKYCSendDocument new];
    pack.docType = docType;
    
    // set document compression
    double const compression = [[LWAuthManager instance].documentsStatus compression:docType];
    pack.imageJPEGRepresentation = UIImageJPEGRepresentation(image, compression);
    
    [self sendPacket:pack];
}

- (void)requestSendDocumentBin:(KYCDocumentType)docType image:(UIImage *)image {
    LWPacketKYCSendDocumentBin *pack = [LWPacketKYCSendDocumentBin new];
    pack.docType = docType;

    // set document compression
    double const compression = [[LWAuthManager instance].documentsStatus compression:docType];
    pack.imageJPEGRepresentation = UIImageJPEGRepresentation(image, compression);
    
    [self sendPacket:pack];
}

- (void)requestKYCStatusGet {
    LWPacketKYCStatusGet *pack = [LWPacketKYCStatusGet new];
    
    [self sendPacket:pack];
}

- (void)requestKYCStatusSet {
    LWPacketKYCStatusSet *pack = [LWPacketKYCStatusSet new];
    
    [self sendPacket:pack];
}

- (void)requestPinSecurityGet:(NSString *)pin {
    LWPacketPinSecurityGet *pack = [LWPacketPinSecurityGet new];
    pack.pin = pin;
    
    [self sendPacket:pack];
}

- (void)requestPinSecuritySet:(NSString *)pin {
    LWPacketPinSecuritySet *pack = [LWPacketPinSecuritySet new];
    pack.pin = pin;
    
    [self sendPacket:pack];
}

- (void)requestRestrictedCountries {
    LWPacketRestrictedCountries *pack = [LWPacketRestrictedCountries new];
    
    [self sendPacket:pack];
}

- (void)requestPersonalData {
    LWPacketPersonalData *pack = [LWPacketPersonalData new];
    
    [self sendPacket:pack];
}

- (void)requestLykkeWallets {
    LWPacketWallets *pack = [LWPacketWallets new];
    
    [self sendPacket:pack];
}

- (void)requestSendLog:(NSString *)log {
    LWPacketLog *pack = [LWPacketLog new];
    pack.log = log;
    
    [self sendPacket:pack];
}

- (void)requestAddBankCard:(LWBankCardsAdd *)card {
    LWPacketBankCards *pack = [LWPacketBankCards new];
    pack.addCardData = card;
    
    [self sendPacket:pack];
}

- (void)requestBaseAssets {
    LWPacketBaseAssets *pack = [LWPacketBaseAssets new];
    
    [self sendPacket:pack];
}

-(void) requestAllAssets
{
    LWPacketAllAssets *pack = [LWPacketAllAssets new];
    
    [self sendPacket:pack];

}

- (void)requestBaseAssetGet {
    LWPacketBaseAssetGet *pack = [LWPacketBaseAssetGet new];
    
    [self sendPacket:pack];
}

- (void)requestBaseAssetSet:(NSString *)assetId {
    LWPacketBaseAssetSet *pack = [LWPacketBaseAssetSet new];
    pack.identity = assetId;
    
    [self sendPacket:pack];
}

-(void) requestLastBaseAssets
{
    LWPacketLastBaseAssets *pack = [LWPacketLastBaseAssets new];
    
    [self sendPacket:pack];

}

- (void)requestAssetPair:(NSString *)pairId {
    LWPacketAssetPair *pack = [LWPacketAssetPair new];
    pack.identity = pairId;
    
    [self sendPacket:pack];
}

- (void)requestAssetPairs {
    if([LWKeychainManager instance].isAuthenticated == false) {
        return;
    }

    LWPacketAssetPairs *pack = [LWPacketAssetPairs new];
    
    [self sendPacket:pack];
}

- (void)requestAssetPairRate:(NSString *)pairId {
#warning this need to be uncomment when we implement generate key
//    if([LWKeychainManager instance].isAuthenticated == false) {
//        return;
//    }
    
    LWPacketAssetPairRate *pack = [LWPacketAssetPairRate new];
    pack.identity = pairId;
    
    [self sendPacket:pack];
}

- (void)requestAssetPairRates {
    if([LWKeychainManager instance].isAuthenticated == false) {
        return;
    }

    LWPacketAssetPairRates *pack = [LWPacketAssetPairRates new];
    pack.ignoreBaseAsset = false;
    [self sendPacket:pack];
}
    
-(void) requestAssetPairRatesNoBaseAsset {
    if([LWKeychainManager instance].isAuthenticated == false) {
        return;
    }

    LWPacketAssetPairRates *pack = [LWPacketAssetPairRates new];
    pack.ignoreBaseAsset = true;
    [self sendPacket:pack];
}

- (void)requestAssetsDescriptions:(NSArray *)assetIds {
    
    LWPacketAssetsDescriptions *pack = [LWPacketAssetsDescriptions new];
    pack.assetsIds = assetIds;
    
    [self sendPacket:pack];
}

- (void)requestAppSettings {
    LWPacketAppSettings *pack = [LWPacketAppSettings new];
    
    [self sendPacket:pack];
}

- (void)requestBuySellAsset:(NSString *)asset assetPair:(NSString *)assetPair volume:(NSNumber *)volume rate:(NSString *)rate {
    LWPacketBuySellAsset *pack = [LWPacketBuySellAsset new];
    pack.baseAsset = asset;
    pack.assetPair = assetPair;
    pack.volume    = volume;
    pack.rate      = rate;
    
    [self sendPacket:pack];
}


- (void)requestSignOrders:(BOOL)shouldSignOrders {
    LWPacketSettingSignOrder *pack = [LWPacketSettingSignOrder new];
    pack.shouldSignOrder = shouldSignOrders;
    
    [self sendPacket:pack];
}

- (void)requestBlockchainOrderTransaction:(NSString *)orderId {
    LWPacketBlockchainTransaction *pack = [LWPacketBlockchainTransaction new];
    pack.orderId = orderId;
    
    [self sendPacket:pack];
}

- (void)requestBlockchainCashTransaction:(NSString *)cashOperationId {
    LWPacketBlockchainCashTransaction *pack = [LWPacketBlockchainCashTransaction new];
    pack.cashOperationId = cashOperationId;
    
    [self sendPacket:pack];
}

- (void)requestBlockchainExchangeTransaction:(NSString *)exchnageOperationId {
    LWPacketBlockchainExchangeTransaction *pack = [LWPacketBlockchainExchangeTransaction new];
    pack.exchangeOperationId = exchnageOperationId;
    
    [self sendPacket:pack];
}

- (void)requestBlockchainTransferTrnasaction:(NSString *)transferOperationId {
    LWPacketBlockchainTransferTransaction *pack = [LWPacketBlockchainTransferTransaction new];
    pack.transferOperationId = transferOperationId;
    
    [self sendPacket:pack];
}

- (void)requestTransactions:(NSString *)assetId {
    LWPacketTransactions *pack = [LWPacketTransactions new];
    pack.assetId = assetId;
    
    [self sendPacket:pack];
}

- (void)requestMarketOrder:(NSString *)orderId {
    LWPacketMarketOrder *pack = [LWPacketMarketOrder new];
    pack.orderId = orderId;
    
    [self sendPacket:pack];
}

- (void)requestEmailBlockchainForAssetId:(NSString *)assetId address:(NSString *) address
{
    LWPacketSendBlockchainEmail *pack = [LWPacketSendBlockchainEmail new];
    pack.assetId=assetId;
    pack.address=address;
    [self sendPacket:pack];
}

- (void)requestExchangeInfo:(NSString *)exchangeId {
    LWPacketExchangeInfoGet *pack = [LWPacketExchangeInfoGet new];
    pack.exchangeId = exchangeId;
    
    [self sendPacket:pack];
}

- (void)requestDictionaries {
    LWPacketDicts *pack = [LWPacketDicts new];
    
    [self sendPacket:pack];
}

- (void)requestCashOut:(NSNumber *)amount assetId:(NSString *)assetId multiSig:(NSString *)multiSig {
    LWPacketCashOut *pack = [LWPacketCashOut new];
    pack.multiSig = multiSig;
    pack.amount = amount;
    pack.assetId = assetId;
    
    [self sendPacket:pack];
}

- (void)requestTransfer:(NSString *)assetId amount:(NSNumber *)amount recipient:(NSString *)recepientId {
    LWPacketTransfer *pack = [LWPacketTransfer new];
    pack.assetId = assetId;
    pack.amount = amount;
    pack.recepientId = recepientId;
    
    [self sendPacket:pack];
}

- (void)requestVerificationEmail:(NSString *)email {
    LWPacketEmailVerificationSet *pack = [LWPacketEmailVerificationSet new];
    pack.email = email;
    
    [self sendPacket:pack];
}

- (void)requestVerificationEmail:(NSString *)email forCode:(NSString *)code {
    LWPacketEmailVerificationGet *pack = [LWPacketEmailVerificationGet new];
    pack.email = email;
    pack.code = code;
    
    [self sendPacket:pack];
}

- (void)requestVerificationPhone:(NSString *)phone {
    LWPacketPhoneVerificationSet *pack = [LWPacketPhoneVerificationSet new];
    pack.phone = phone;
    
    [self sendPacket:pack];
}

- (void)requestVerificationPhone:(NSString *)phone forCode:(NSString *)code {
    LWPacketPhoneVerificationGet *pack = [LWPacketPhoneVerificationGet new];
    pack.phone = phone;
    pack.code = code;
    
    [self sendPacket:pack];
}

- (void)requestSetFullName:(NSString *)fullName {
    LWPacketClientFullNameSet *pack = [LWPacketClientFullNameSet new];
    pack.fullName = fullName;
    
    [self sendPacket:pack];
}

- (void)requestCountyCodes {
    LWPacketCountryCodes *pack = [LWPacketCountryCodes new];
    
    [self sendPacket:pack];
}

-(void) requestGraphPeriods
{
    LWPacketGraphPeriods *pack=[LWPacketGraphPeriods new];
    
    [self sendPacket:pack];
}

-(void) requestGraphDataForPeriod:(LWGraphPeriodModel *)period  assetPairId:(NSString *)assetPairId points:(int)points
{
    LWPacketGraphData *pack=[LWPacketGraphData new];
    pack.period=period;
    pack.assetId=assetPairId;
    pack.points = points;
    [self sendPacket:pack];
    
}

-(void) requestCurrencyDepositForAsset:(NSString *)assetId changeValue:(NSNumber *)changeValue
{
    LWPacketCurrencyDeposit *pack=[LWPacketCurrencyDeposit new];
    pack.assetId=assetId;
    pack.balanceChange=changeValue;
    [self sendPacket:pack];
}

-(void) requestCurrencyWithdraw:(LWPacketCurrencyWithdraw *)withdraw
{
    [self sendPacket:(LWPacket *)withdraw];
}

-(void) requestAPIVersion
{
    LWPacketApplicationInfo *pack=[LWPacketApplicationInfo new];
    [self sendPacket:(LWPacket *) pack];
}

-(void) validateBitcoinAddress:(NSString *) address
{
    LWPacketBitcoinAddressValidation *pack=[LWPacketBitcoinAddressValidation new];
    pack.bitcoinAddress=address;
    [self sendPacket:pack];
}

-(void) requestSetReverted:(BOOL)reverted assetPairId:(NSString *)assetPairId
{
    LWPacketSetRevertedPair *pack=[LWPacketSetRevertedPair new];
    pack.inverted=reverted;
    pack.assetPairId=assetPairId;
    [self sendPacket:pack];
}

-(void) requestKYCStatusForAsset:(NSString *)assetId
{
    LWPacketKYCForAsset *pack=[LWPacketKYCForAsset new];
    pack.assetId=assetId;
    [self sendPacket:pack];
}

-(void) requestGetRefundAddress
{
    LWPacketGetRefundAddress *pack=[LWPacketGetRefundAddress new];
    [self sendPacket:pack];
}

-(void) requestSetRefundAddress:(NSDictionary *) dict
{
    LWPacketSetRefundAddress *pack=[LWPacketSetRefundAddress new];
    pack.refundDict=dict;;
    [self sendPacket:pack];
}


-(void) setDelegate:(id<LWAuthManagerDelegate>)delegate //Andrey
{
    _delegate=delegate;
}

-(void) requestGetPushSettings
{
    LWPacketPushSettingsGet *pack=[[LWPacketPushSettingsGet alloc] init];
    [self sendPacket:pack];
}

-(void) requestSetPushEnabled:(BOOL)isEnabled
{
    LWPacketPushSettingsSet *pack=[[LWPacketPushSettingsSet alloc] init];
    pack.enabled=isEnabled;
    [self sendPacket:pack];
}

-(void) requestEncodedPrivateKey
{
    LWPacketEncodedPrivateKey *pack=[[LWPacketEncodedPrivateKey alloc] init];
    [self sendPacket:pack];
}

-(void) requestSaveClientKeysWithPubKey:(NSString *)pubKey encodedPrivateKey:(NSString *)encodedPrivateKey
{
    LWPacketClientKeys *pack=[[LWPacketClientKeys alloc] init];
    pack.pubKey=pubKey;
    pack.encodedPrivateKey=encodedPrivateKey;
    [self sendPacket:pack];
}

-(void) requestGetPaymentUrlWithParameters:(NSDictionary *)params
{
    LWPacketGetPaymentUrl *pack=[[LWPacketGetPaymentUrl alloc] init];
    pack.parameters=params;
    [self sendPacket:pack];
}

-(void) requestPrevCardPayment
{
    LWPacketPrevCardPayment *pack=[[LWPacketPrevCardPayment alloc] init];
    [self sendPacket:pack];
}

-(void) requestGetHistory:(NSString *) assetId
{
    LWPacketGetHistory *pack=[[LWPacketGetHistory alloc] init];
    pack.assetId=assetId;
    [self sendPacket:pack];
}

-(void) requestPrivateKeyOwnershipMessage:(NSString *)email
{
    LWPrivateKeyOwnershipMessage *pack=[[LWPrivateKeyOwnershipMessage alloc] init];
    pack.email=email;
    [self sendPacket:pack];
}

-(void) requestCheckPrivateKeyOwnershipMessageSignature:(NSString *)signature email:(NSString *)email
{
    LWPrivateKeyOwnershipMessage *pack=[[LWPrivateKeyOwnershipMessage alloc] init];
    pack.email=email;
    pack.signature=signature;
    [self sendPacket:pack];

}

-(void) requestRecoverySMSConfirmation:(LWRecoveryPasswordModel *)recModel
{
    LWPacketRecoverySMSConfirmation *pack=[LWPacketRecoverySMSConfirmation new];
    pack.recModel=recModel;
    [self sendPacket:pack];
}

-(void) requestChangePINAndPassword:(LWRecoveryPasswordModel *)recModel
{
    LWPacketChangePINAndPassword *pack=[LWPacketChangePINAndPassword new];
    pack.recModel=recModel;
    [self sendPacket:pack];
}

-(void) requestAllAssetPairsRates:(NSString *)assetId
{
    LWPacketAllAssetPairsRates *pack=[LWPacketAllAssetPairsRates new];
    pack.assetId=assetId;
    [self sendPacket:pack];
}

-(void) requestMyLykkeInfo
{
    LWPacketMyLykkeInfo *pack=[LWPacketMyLykkeInfo new];
    [self sendPacket:pack];
}

-(void) requestAllAssetPairs
{
    LWPacketAllAssetPairs *pack=[LWPacketAllAssetPairs new];
    [self sendPacket:pack];
}

-(void) requestLykkeNewsWithCompletion:(void (^)(NSArray *))completion
{
    LWPacketGetNews *pack=[LWPacketGetNews new];
    pack.completion=completion;
    [self sendPacket:pack];
}

-(void) requestSwiftCredentials
{
    LWPacketSwiftCredentials *pack=[LWPacketSwiftCredentials new];
    [self sendPacket:pack];
}
    
-(void) requestSwiftCredential:(NSString *)assetId
{
    LWPacketSwiftCredential *pack=[LWPacketSwiftCredential new];
    pack.identity = assetId;
    
    [self sendPacket:pack];
}

-(void) requestMyLykkeSettings
{
    LWPacketLykkeSettings *pack=[LWPacketLykkeSettings new];
    [self sendPacket:pack];
}

-(void) requestSendMyLykkeCashInEmail:(NSDictionary *)params
{
    LWPacketMyLykkeCashInEmail *pack=[LWPacketMyLykkeCashInEmail new];
    pack.assetId=params[@"AssetId"];
    pack.amount=params[@"Amount"];
    pack.lkkAmount=params[@"LkkAmount"];
    pack.price=params[@"Price"];
    [self sendPacket:pack];
}

-(void) requestEthereumAddress
{
    LWPacketGetEthereumAddress *pack=[LWPacketGetEthereumAddress new];
    [self sendPacket:pack];
}

-(void) requestSendHintForEmail:(NSString *)email
{
    LWPacketEmailHint *pack=[LWPacketEmailHint new];
    pack.email=email;
    [self sendPacket:pack];
}


-(void) requestSaveBackupState
{
    LWPacketSaveBackupState *pack=[LWPacketSaveBackupState new];
    [self sendPacket:pack];
    
}

-(void) requestVoiceCall:(NSString *) phone email:(NSString *) email
{
    LWPacketVoiceCall *pack=[LWPacketVoiceCall new];
    pack.phone=phone;
    pack.email=email;
    [self sendPacket:pack];
}

-(void) requestWalletMigration:(LWWalletMigrationModel *)migration
{
    LWPacketWalletMigration *pack=[LWPacketWalletMigration new];
    pack.migration=migration;
    [self sendPacket:pack];
}

-(void) requestSetPasswordHash:(NSString *)hash
{
    LWPacketPasswordHashSet *pack=[LWPacketPasswordHashSet new];
    pack.passwordHash=hash;
    [self sendPacket:pack];
}

-(void) requestOrderBook:(NSString *)assetPairId
{
    LWPacketOrderBook *pack=[LWPacketOrderBook new];
    pack.assetPairId=assetPairId;
    [self sendPacket:pack];
}

-(void) requestKYCDocuments
{
    LWPacketKYCDocuments *pack=[LWPacketKYCDocuments new];
    [self sendPacket:pack];
}

-(void) requestAssetCategories
{
    LWPacketCategories *pack=[LWPacketCategories new];
    [self sendPacket:pack];
}

-(void) requestPendingTransactions
{
    if([LWKeychainManager instance].isAuthenticated)
    {
        LWPacketGetPendingTransactions *pack=[LWPacketGetPendingTransactions new];
        [self sendPacket:pack];
    }
}

-(void) requestSendSignedTransaction:(LWSignRequestModel *)signRequest
{
    LWPacketSendSignedTransaction *pack=[LWPacketSendSignedTransaction new];
    pack.signRequest=signRequest;
    [self sendPacket:pack];
    
}

-(void) requestEthereumContractForAddress:(NSString *)address pubKey:(NSString *)pubKey
{
    LWPacketGetEthereumContract *pack=[LWPacketGetEthereumContract new];
    pack.address=address;
    pack.pubKey=pubKey;
    [self sendPacket:pack];
}

-(void) requestSendEmailPrivateWalletsAddress:(NSString *)address name:(NSString *)name
{
    LWPacketEmailPrivateWalletAddress *pack=[LWPacketEmailPrivateWalletAddress new];
    pack.address=address;
    pack.name=name;
    [self sendPacket:pack];
}

-(void) requestMarketConverter:(NSDictionary *)assetsDict lkkAssetId:(NSString *) lkkAssetId
{
    LWPacketMarketConverter *pack=[LWPacketMarketConverter new];
    pack.assetsDict=assetsDict;
    pack.lkkAssetId = lkkAssetId;
    [self sendPacket:pack];
}

-(void) requestSendSolarCoinAddressEmail:(NSString *)address
{
    LWPacketSolarCoinEmail *pack=[LWPacketSolarCoinEmail new];
    pack.address=address;
    [self sendPacket:pack];
}

-(void) requestIssuers
{
    LWPacketGetIssuers *pack=[LWPacketGetIssuers new];
    [self sendPacket:pack];
}


-(void) requestLogout {
    LWPacketLogout *pack = [LWPacketLogout new];
    [self sendPacket:pack];
}

-(void) requestCFDWatchLists {
    LWPacketGetCFDWatchLists *pack = [LWPacketGetCFDWatchLists new];
    [self sendPacket:pack];
}

-(void) requestSpotWatchLists {
    LWPacketGetSpotWatchLists *pack = [LWPacketGetSpotWatchLists new];
    [self sendPacket:pack];

}

-(void) requestSaveWatchList:(LWWatchList *)watchList
{
    LWPacketSaveWatchList *pack = [LWPacketSaveWatchList new];
    pack.watchList = watchList;
    [self sendPacket:pack];
}

-(void) requestDeleteWatchList:(LWWatchList *)watchList
{
    LWPacketDeleteWatchList *pack = [LWPacketDeleteWatchList new];
    pack.watchList = watchList;
    [self sendPacket:pack];
}

-(void) requestBlockchainAddressForAssetId:(NSString *)assetId
{
    LWPacketGetBlockchainAddress *pack = [LWPacketGetBlockchainAddress new];
    pack.assetId = assetId;
    [self sendPacket:pack];
}

-(void) requestSettleForwardWithdrawForAsset:(LWAssetModel *)asset amount:(double)amount {
    LWPacketSettleForwardWithdraw *pack = [LWPacketSettleForwardWithdraw new];
    pack.asset = asset;
    pack.amount = amount;
    [self sendPacket:pack];
}

-(void) requestCheckIsUSAUser:(NSString *)phone {
    LWPacketCheckIsUSAUser *pack = [LWPacketCheckIsUSAUser new];
    pack.phoneNumber = phone;
    [self sendPacket:pack];
}

-(void) requestSetUSAUser:(BOOL) flag {
    LWPacketSetUSAUser *pack = [LWPacketSetUSAUser new];
    pack.isUserFromUSA = flag;
    [self sendPacket:pack];
}

-(void) requestCheckPendingActions {
    LWPacketCheckPendingActions *pack = [LWPacketCheckPendingActions new];
    [self sendPacket:pack];
}

-(void) requestGetUnsignedSPOTTransactions {
    LWPacketGetUnsignedSPOTTransactions *pack = [LWPacketGetUnsignedSPOTTransactions new];
    [self sendPacket:pack];
}

-(void) requestSendSignedSPOTTransactions:(NSArray *)transactions {
    LWPacketSendSignedSPOTTransactions *pack = [LWPacketSendSignedSPOTTransactions new];
    pack.transactions = transactions;
    [self sendPacket:pack];
}

-(void) requestMainScreenInfo {
    LWPacketGetMainScreenInfo *pack = [LWPacketGetMainScreenInfo new];
    [self sendPacket:pack];
}

-(void) requestMainScreenInfo: (NSString *) assetId {
    LWPacketGetMainScreenInfo *pack = [LWPacketGetMainScreenInfo new];
    pack.assetId = assetId;
    [self sendPacket:pack];
}

-(void) requestGetMarginTermsStatus {
    LWPacketGetMarginTermsStatus *pack = [LWPacketGetMarginTermsStatus new];
    [self sendPacket:pack];
}

-(void) requestSetMarginTermsStatus {
    LWPacketSetMarginTermsStatus *pack = [LWPacketSetMarginTermsStatus new];
    [self sendPacket:pack];
}

-(void) requestMarginalDepositWithdrawForAccountId:(NSString *)accountId amount:(NSNumber *)amount {
    LWPacketMarginDepositWithdraw *pack = [LWPacketMarginDepositWithdraw new];
    pack.accountId = accountId;
    pack.amount = amount;
    [self sendPacket:pack];
}

-(void) requestResetDemoMarginAccount:(NSString *)accountId {
    LWPacketResetDemoMarginAccount *pack = [LWPacketResetDemoMarginAccount new];
    pack.accountId = accountId;
    [self sendPacket:pack];
}

#pragma mark - Observing

- (void)observeGDXNetAdapterDidReceiveResponseNotification:(NSNotification *)notification {
    GDXRESTContext *ctx = notification.userInfo[kNotificationKeyGDXNetContext];
    LWPacket *pack = (LWPacket *)ctx.packet;
    
    if([pack isKindOfClass:[LWPacketGetMainScreenInfo class]] && [(LWPacketGetMainScreenInfo *)pack success] == false) {
        return;
    }
    // decline rejected packet
    id delegate=self.delegate;
    if(pack.caller)
        self.delegate=pack.caller;

    if (pack.isRejected) {
        [self observeGDXNetAdapterDidFailRequestNotification:notification];
        // return immediately
        return;
    }
    
    @synchronized (@"call_delegate") {
        
  

    // parse packet by class
    if (pack.class == LWPacketAccountExist.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didCheckRegistration:)])  {
            LWPacketAccountExist *account = (LWPacketAccountExist *)pack;
            [self.delegate authManager:self
                  didCheckRegistration:account];
        }
    }
    else if (pack.class == LWPacketAuthentication.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidAuthenticate:KYCStatus:isPinEntered:)]) {
            LWPacketAuthentication *auth = (LWPacketAuthentication *)pack;
            [self.delegate authManagerDidAuthenticate:self
                                            KYCStatus:auth.status
                                         isPinEntered:auth.isPinEntered];
        }
    }
    else if (pack.class == LWPacketRegistration.class) {
        // set self registration data
        _registrationData = ((LWPacketRegistration *)pack).registrationData;
        // call delegate
        if ([self.delegate respondsToSelector:@selector(authManagerDidRegister:)]) {
            [self.delegate authManagerDidRegister:self];
        }
    }
    else if (pack.class == LWPacketRegistrationGet.class) {
        // call delegate
        if ([self.delegate respondsToSelector:@selector(authManagerDidRegisterGet:KYCStatus:isPinEntered:personalData:)]) {
            LWPacketRegistrationGet *packet = (LWPacketRegistrationGet *)pack;
            [self.delegate authManagerDidRegisterGet:self
                                           KYCStatus:packet.status
                                        isPinEntered:packet.isPinEntered
                                        personalData:packet.personalData];
        }
    }
    else if (pack.class == LWPacketPersonalData.class) {
        // call delegate
        if ([self.delegate respondsToSelector:@selector(authManager:didReceivePersonalData:)]) {
            [self.delegate authManager:self didReceivePersonalData:((LWPacketPersonalData *)pack).data];
        }
    }
    else if (pack.class == LWPacketCheckDocumentsToUpload.class) {
        // set self documents status
        _documentsStatus = ((LWPacketCheckDocumentsToUpload *)pack).documentsStatus;
        // call delegate
        if ([self.delegate respondsToSelector:@selector(authManager:didCheckDocumentsStatus:)]) {
            [self.delegate authManager:self didCheckDocumentsStatus:self.documentsStatus];
        }
    }
    else if (pack.class == LWPacketKYCSendDocument.class ||
             pack.class == LWPacketKYCSendDocumentBin.class) {
        KYCDocumentType docType = ((LWPacketKYCSendDocument *)pack).docType;
        // modify self documents status
        [self.documentsStatus setTypeUploaded:docType withImage:nil];
        [self.documentsStatus setCroppedStatus:docType withCropped:NO];
        // call delegate
        if ([self.delegate respondsToSelector:@selector(authManagerDidSendDocument:ofType:)]) {
            [self.delegate authManagerDidSendDocument:self ofType:docType];
        }
    }
    else if (pack.class == LWPacketKYCStatusGet.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetKYCStatus: personalData:)]) {
            LWPacketKYCStatusGet *packet = (LWPacketKYCStatusGet *)pack;
            [self.delegate authManager:self
                       didGetKYCStatus:packet.status
                          personalData:packet.personalData];
        }
    }
    else if (pack.class == LWPacketKYCStatusSet.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSetKYCStatus:)]) {
            [self.delegate authManagerDidSetKYCStatus:self];
        }
    }
    else if (pack.class == LWPacketPinSecurityGet.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didValidatePin:)]) {
            [self.delegate authManager:self didValidatePin:((LWPacketPinSecurityGet *)pack).isPassed];
        }
    }
    else if (pack.class == LWPacketPinSecuritySet.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSetPin:)]) {
            [self.delegate authManagerDidSetPin:self];
        }
    }
    else if (pack.class == LWPacketRestrictedCountries.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didReceiveRestrictedCountries:)]) {
            [self.delegate authManager:self
         didReceiveRestrictedCountries:((LWPacketRestrictedCountries *)pack).countries];
        }
    }
    else if (pack.class == LWPacketWallets.class) {
        // recieved data with all wallets
        if ([self.delegate respondsToSelector:@selector(authManager:didReceiveLykkeData:)]) {
            [self.delegate authManager:self didReceiveLykkeData:((LWPacketWallets *)pack).data];
        }
    }
    else if (pack.class == LWPacketLog.class) {
        // nothing to do
    }
    else if (pack.class == LWPacketBankCards.class) {
        // receiving confirmation about added credit card
        if ([self.delegate respondsToSelector:@selector(authManagerDidCardAdd:)]) {
            [self.delegate authManagerDidCardAdd:self];
        }
    }
    else if (pack.class == LWPacketBaseAssets.class) {
        // receiving assets catalog
        if ([self.delegate respondsToSelector:@selector(authManager:didGetBaseAssets:)]) {
            [self.delegate authManager:self didGetBaseAssets:((LWPacketBaseAssets *)pack).assets];
        }
    }
    else if (pack.class == LWPacketBaseAssetGet.class) {
        // receving base asset
        if ([self.delegate respondsToSelector:@selector(authManager: didGetBaseAsset:)]) {
            [self.delegate authManager:self didGetBaseAsset:((LWPacketBaseAssetGet *)pack).asset];
        }
    }
    else if (pack.class == LWPacketBaseAssetSet.class) {
        // receiving base asset set confirmation
        if ([self.delegate respondsToSelector:@selector(authManagerDidSetAsset:)]) {
            [self.delegate authManagerDidSetAsset:self];
        }
    }
    else if (pack.class == LWPacketAssetPair.class) {
        // receiving asset pair by id
        if ([self.delegate respondsToSelector:@selector(authManager:didGetAssetPair:)]) {
            [self.delegate authManager:self didGetAssetPair:((LWPacketAssetPair *)pack).assetPair];
        }
    }
    else if (pack.class == LWPacketAssetPairs.class) {
        // receiving asset pairs
        if ([self.delegate respondsToSelector:@selector(authManager:didGetAssetPairs:)]) {
            [self.delegate authManager:self didGetAssetPairs:((LWPacketAssetPairs *)pack).assetPairs];
        }
    }
    else if (pack.class == LWPacketAssetPairRate.class) {
        // receiving asset pair rate by id
        if ([self.delegate respondsToSelector:@selector(authManager:didGetAssetPairRate:)]) {
            [self.delegate authManager:self didGetAssetPairRate:((LWPacketAssetPairRate *)pack).assetPairRate];
        }
    }
    else if (pack.class == LWPacketAssetPairRates.class) {
        // receiving asset pair rates
        if ([self.delegate respondsToSelector:@selector(authManager:didGetAssetPairRates:)]) {
            [self.delegate authManager:self didGetAssetPairRates:((LWPacketAssetPairRates *)pack).assetPairRates];
        }
    }
    else if (pack.class == LWPacketAssetsDescriptions.class) {
        // receiving asset description
        if ([self.delegate respondsToSelector:@selector(authManager:didGetAssetsDescriptions:)]) {
            [self.delegate authManager:self didGetAssetsDescriptions:((LWPacketAssetsDescriptions *)pack).assetsDescriptions];
        }
    }
    else if (pack.class == LWPacketAppSettings.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetAppSettings:)]) {
            [self.delegate authManager:self didGetAppSettings:((LWPacketAppSettings *)pack).appSettings];
        }
    }
    else if (pack.class == LWPacketBuySellAsset.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didReceiveDealResponse:)]) {
            [self.delegate authManager:self didReceiveDealResponse:((LWPacketBuySellAsset *)pack).deal];
        }
    }
    else if (pack.class == LWPacketSettingSignOrder.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSetSignOrders:)]) {
            [self.delegate authManagerDidSetSignOrders:self];
        }
    }
    else if (pack.class == LWPacketBlockchainTransaction.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetBlockchainTransaction:)]) {
            [self.delegate authManager:self didGetBlockchainTransaction:((LWPacketBlockchainTransaction *)pack).blockchain];
        }
    }
    else if (pack.class == LWPacketBlockchainCashTransaction.class) {
        if ([self.delegate respondsToSelector:@selector(authManager: didGetBlockchainCashTransaction:)]) {
            [self.delegate authManager:self didGetBlockchainCashTransaction:((LWPacketBlockchainCashTransaction *)pack).blockchain];
        }
    }
    else if (pack.class == LWPacketBlockchainExchangeTransaction.class) {
        if ([self.delegate respondsToSelector:@selector(authManager: didGetBlockchainExchangeTransaction:)]) {
            [self.delegate authManager:self didGetBlockchainExchangeTransaction:((LWPacketBlockchainExchangeTransaction *)pack).blockchain];
        }
    }
    else if (pack.class == LWPacketBlockchainTransferTransaction.class) {
        if ([self.delegate respondsToSelector:@selector(authManager: didGetBlockchainTransferTransaction:)]) {
            [self.delegate authManager:self didGetBlockchainTransferTransaction:((LWPacketBlockchainTransferTransaction *)pack).blockchain];
        }
    }
    else if (pack.class == LWPacketTransactions.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didReceiveTransactions:)]) {
            [self.delegate authManager:self didReceiveTransactions:((LWPacketTransactions *)pack).model];
        }
    }
    else if (pack.class == LWPacketMarketOrder.class) {
        // receiving market order info
        if ([self.delegate respondsToSelector:@selector(authManager:didReceiveMarketOrder:)]) {
            [self.delegate authManager:self didReceiveMarketOrder:((LWPacketMarketOrder *)pack).model];
        }
    }
    else if (pack.class == LWPacketSendBlockchainEmail.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSendBlockchainEmail:)]) {
            [self.delegate authManagerDidSendBlockchainEmail:self];
        }
    }
    else if (pack.class == LWPacketExchangeInfoGet.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didReceiveExchangeInfo:)]) {
            [self.delegate authManager:self didReceiveExchangeInfo:((LWPacketExchangeInfoGet *)pack).model];
        }
    }
    else if (pack.class == LWPacketDicts.class) {
        if ([self.delegate respondsToSelector:@selector(authManager: didReceiveAssetDicts:)]) {
            [self.delegate authManager:self didReceiveAssetDicts:((LWPacketDicts *)pack).assetsDictionary];
        }
    }
    else if (pack.class == LWPacketCashOut.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidCashOut:)]) {
            [self.delegate authManagerDidCashOut:self];
        }
    }
    else if (pack.class == LWPacketTransfer.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidTransfer:)]) {
            [self.delegate authManagerDidTransfer:self];
        }
    }
    else if (pack.class == LWPacketEmailVerificationGet.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidCheckValidationEmail:passed:)]) {
            [self.delegate authManagerDidCheckValidationEmail:self passed:((LWPacketEmailVerificationGet *)pack).isPassed];
        }
    }
    else if (pack.class == LWPacketEmailVerificationSet.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSendValidationEmail:)]) {
            [self.delegate authManagerDidSendValidationEmail:self];
        }
    }
    else if (pack.class == LWPacketPhoneVerificationGet.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidCheckValidationPhone:passed:)]) {
            [self.delegate authManagerDidCheckValidationPhone:self passed:((LWPacketPhoneVerificationGet *)pack).isPassed];
        }
    }
    else if (pack.class == LWPacketPhoneVerificationSet.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSendValidationPhone:)]) {
            [self.delegate authManagerDidSendValidationPhone:self];
        }
    }
    else if (pack.class == LWPacketClientFullNameSet.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSetFullName:)]) {
            [self.delegate authManagerDidSetFullName:self];
        }
    }
    else if (pack.class == LWPacketCountryCodes.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetCountryCodes:)]) {
            [self.delegate authManager:self didGetCountryCodes:(LWPacketCountryCodes *) pack];
        }
    }
    else if (pack.class == LWPacketGraphPeriods.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetGraphPeriods:)]) {
            [self.delegate authManager:self didGetGraphPeriods:(LWPacketGraphPeriods *) pack];
        }
    }
    else if (pack.class == LWPacketGraphData.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetGraphData:)]) {
            [self.delegate authManager:self didGetGraphData:(LWPacketGraphData *) pack];
        }
    }
    else if (pack.class == LWPacketCurrencyDeposit.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetCurrencyDeposit:)]) {
            [self.delegate authManager:self didGetCurrencyDeposit:(LWPacketCurrencyDeposit *) pack];
        }
    }
    else if (pack.class == LWPacketCurrencyWithdraw.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didSendWithdraw:)]) {
            [self.delegate authManager:self didSendWithdraw:(LWPacketCurrencyWithdraw *) pack];
        }
    }
    else if (pack.class == LWPacketApplicationInfo.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetAPIVersion:)]) {
            [self.delegate authManager:self didGetAPIVersion:(LWPacketApplicationInfo *) pack];
        }
    }
    else if (pack.class == LWPacketBitcoinAddressValidation.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didValidateBitcoinAddress:)]) {
            [self.delegate authManager:self didValidateBitcoinAddress:(LWPacketBitcoinAddressValidation *) pack];
        }
    }
    else if (pack.class == LWPacketLastBaseAssets.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetLastBaseAssets:)]) {
            [self.delegate authManager:self didGetLastBaseAssets:(LWPacketLastBaseAssets *)pack];
        }
    }
    else if (pack.class == LWPacketKYCForAsset.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetAssetKYCStatusForAsset:)]) {
            [self.delegate authManager:self didGetAssetKYCStatusForAsset:(LWPacketKYCForAsset *)pack];
        }
    }
    else if (pack.class == LWPacketGetRefundAddress.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetRefundAddress:)]) {
            [self.delegate authManager:self didGetRefundAddress:(LWPacketGetRefundAddress *)pack];
        }
    }
    else if (pack.class == LWPacketSetRefundAddress.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSetRefundAddress:)]) {
            [self.delegate authManagerDidSetRefundAddress:self];
        }
    }
    else if (pack.class == LWPacketPushSettingsGet.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetPushSettings:)]) {
            [self.delegate authManager:self didGetPushSettings:(LWPacketPushSettingsGet *)pack];
        }
    }
    else if (pack.class == LWPacketPushSettingsSet.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSetPushSettings)]) {
            [self.delegate authManagerDidSetPushSettings];
        }
    }
    else if (pack.class == LWPacketGetPaymentUrl.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetPaymentUrl:)]) {
            [self.delegate authManager:self  didGetPaymentUrl:(LWPacketGetPaymentUrl *)pack];
        }
    }
    else if (pack.class == LWPacketPrevCardPayment.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetLastCardPaymentData:)]) {
            [self.delegate authManager:self  didGetLastCardPaymentData:(LWPacketPrevCardPayment *) pack];
        }
    }
    else if (pack.class == LWPacketGetHistory.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetHistory:)]) {
            [self.delegate authManager:self  didGetHistory:(LWPacketGetHistory *) pack];
        }
    }
    
    else if (pack.class == LWPacketGetHistory.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetHistory:)]) {
            [self.delegate authManager:self  didGetHistory:(LWPacketGetHistory *) pack];
        }
    }
    else if (pack.class == LWPacketClientKeys.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSendClientKeys:)]) {
            [self.delegate authManagerDidSendClientKeys:self];
        }
    }
    else if (pack.class == LWPrivateKeyOwnershipMessage.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetPrivateKeyOwnershipMessage:)]) {
            [self.delegate authManager:(LWAuthManager *)self didGetPrivateKeyOwnershipMessage:(LWPrivateKeyOwnershipMessage *)pack];
        }
    }
    else if (pack.class == LWPacketRecoverySMSConfirmation.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidGetRecoverySMSConfirmation:)]) {
            [self.delegate authManagerDidGetRecoverySMSConfirmation:self];
        }
    }
    else if (pack.class == LWPacketChangePINAndPassword.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidChangePINAndPassword:)]) {
            [self.delegate authManagerDidChangePINAndPassword:self];
        }
    }
    else if (pack.class == LWPacketAllAssetPairs.class) {
         if ([self.delegate respondsToSelector:@selector(authManager:didGetAllAssetPairs:)]) {
                [self.delegate authManager:(LWAuthManager *)self didGetAllAssetPairs:[(LWPacketAllAssetPairs *)pack assetPairs]];
        }
    }

    else if (pack.class == LWPacketAllAssetPairsRates.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetAllAssetPairsRate:)]) {
            [self.delegate authManager:(LWAuthManager *)self didGetAllAssetPairsRate:(LWPacketAllAssetPairsRates *) pack];
        }
    }
    else if (pack.class == LWPacketMyLykkeInfo.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetMyLykkeInfo:)]) {
            [self.delegate authManager:(LWAuthManager *)self didGetMyLykkeInfo:(LWPacketMyLykkeInfo *) pack];
        }
    }
    else if (pack.class == LWPacketMyLykkeCashInEmail.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSendMyLykkeCashInEmail:)]) {
            [self.delegate authManagerDidSendMyLykkeCashInEmail:self];
        }
    }
    else if (pack.class == LWPacketSwiftCredentials.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidGetSwiftCredentials:)]) {
            [self.delegate authManagerDidGetSwiftCredentials:(LWPacketSwiftCredentials *) pack];
        }
    }
    else if (pack.class == LWPacketSwiftCredential.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidGetSwiftCredential:)]) {
            [self.delegate authManagerDidGetSwiftCredential:(LWPacketSwiftCredential *) pack];
        }
    }
    else if (pack.class == LWPacketGetEthereumAddress.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidGetEthereumAddress:)]) {
            [self.delegate authManagerDidGetEthereumAddress:(LWPacketGetEthereumAddress *)pack];
        }
    }
    else if (pack.class == LWPacketEncodedPrivateKey.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidGetEncodedPrivateKey:)]) {
            [self.delegate authManagerDidGetEncodedPrivateKey:self];
        }
    }
    else if (pack.class == LWPacketEmailHint.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSendEmailHint:)]) {
            [self.delegate authManagerDidSendEmailHint:self];
        }
    }
    else if (pack.class == LWPacketVoiceCall.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidRequestVoiceCall:)]) {
            [self.delegate authManagerDidRequestVoiceCall:self];
        }
    }
    else if (pack.class == LWPacketWalletMigration.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidCompleteWalletMigration:)]) {
            [self.delegate authManagerDidCompleteWalletMigration:self];
        }
    }
    else if (pack.class == LWPacketOrderBook.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetOrderBook:)]) {
            [self.delegate authManager:self didGetOrderBook:(LWPacketOrderBook *)pack];
        }
    }
    else if (pack.class == LWPacketKYCDocuments.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetKYCDocuments:)]) {
            [self.delegate authManager:self didGetKYCDocuments:(LWPacketKYCDocuments *)pack];
        }
    }
    else if (pack.class == LWPacketCategories.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetAssetCategories:)]) {
            [self.delegate authManager:self didGetAssetCategories:(LWPacketCategories *)pack];
        }
    }
    else if(pack.class==LWPacketGetEthereumContract.class) {
        if ([self.delegate respondsToSelector:@selector(authManager:didGetEthereumContract:)]) {
            [self.delegate authManager:self didGetEthereumContract:(LWPacketGetEthereumContract *) pack];
        }
    }
    else if(pack.class==LWPacketEmailPrivateWalletAddress.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSendEmailPrivateWalletAddress:)]) {
            [self.delegate authManagerDidSendEmailPrivateWalletAddress:self];
        }
    }
    else if(pack.class==LWPacketMarketConverter.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidGetMarketConverter:)]) {
            [self.delegate authManagerDidGetMarketConverter:(LWPacketMarketConverter *) pack];
        }
    }
    else if(pack.class==LWPacketSolarCoinEmail.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSendSolarCoinEmail:)]) {
            [self.delegate authManagerDidSendSolarCoinEmail:self];
        }
    }
    else if(pack.class==LWPacketGetCFDWatchLists.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidGetCFDWatchLists:)]) {
            [self.delegate authManagerDidGetCFDWatchLists:self];
        }
    }
    else if(pack.class==LWPacketGetSpotWatchLists.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidGetSpotWatchLists:)]) {
            [self.delegate authManagerDidGetSpotWatchLists:self];
        }
    }
    else if(pack.class==LWPacketGetBlockchainAddress.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidGetBlockchainAddress:)]) {
            [self.delegate authManagerDidGetBlockchainAddress:(LWPacketGetBlockchainAddress *) pack];
        }
    }
    else if(pack.class==LWPacketSettleForwardWithdraw.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidSendSettleRequest)]) {
            [self.delegate authManagerDidSendSettleRequest];
        }
    }
    else if(pack.class==LWPacketCheckIsUSAUser.class) {
        if ([self.delegate respondsToSelector:@selector(authManagerDidCheckIsUSANumber:)]) {
            [self.delegate authManagerDidCheckIsUSANumber:(LWPacketCheckIsUSAUser *)pack];
        }
    }
    else if(pack.class == LWPacketAllAssets.class) {
        if([self.delegate respondsToSelector:@selector(authManagerDidGetAllAssets)]) {
            [self.delegate authManagerDidGetAllAssets];
        }
    }
    else if(pack.class == LWPacketCheckPendingActions.class) {
        if([self.delegate respondsToSelector:@selector(authManagerDidCheckPendingActions:)]) {
            [self.delegate authManagerDidCheckPendingActions:(LWPacketCheckPendingActions *)pack];
        }
    }
    else if(pack.class == LWPacketGetUnsignedSPOTTransactions.class) {
        if([self.delegate respondsToSelector:@selector(authManagerDidGetUnsignedSPOTTransactions:)]) {
            [self.delegate authManagerDidGetUnsignedSPOTTransactions:(LWPacketGetUnsignedSPOTTransactions *) pack];
        }
    }
    else if(pack.class == LWPacketGetMainScreenInfo.class) {
        if([self.delegate respondsToSelector:@selector(authManagerDidGetMainScreenInfo:)]) {
            [self.delegate authManagerDidGetMainScreenInfo:(LWPacketGetMainScreenInfo *) pack];
        }
    }
    else if(pack.class == LWPacketSetMarginTermsStatus.class) {
        if([self.delegate respondsToSelector:@selector(authManagerDidSetMarginTermsStatus)]) {
            [self.delegate authManagerDidSetMarginTermsStatus];
        }
    }
    else if(pack.class == LWPacketMarginDepositWithdraw.class) {
        if([self.delegate respondsToSelector:@selector(authManagerDidSendMarginDepositWithdraw:)]) {
            [self.delegate authManagerDidSendMarginDepositWithdraw:(LWPacketMarginDepositWithdraw *) pack];
        }
    }
    
        
        
        self.delegate=delegate;
          }

}

- (void)observeGDXNetAdapterDidFailRequestNotification:(NSNotification *)notification {
    
    GDXRESTContext *ctx = notification.userInfo[kNotificationKeyGDXNetContext];
    LWPacket *pack = (LWPacket *)ctx.packet;
    
    if([pack isKindOfClass:[LWPacketGetMainScreenInfo class]]) {
        return;
    }

    
    // check if user not authorized - kick them
    if ([LWAuthManager isAuthneticationFailed:ctx.task.response]) {
//        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"You are not authorised" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]; //Testing
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [alert show];
//        });
        NSString *http=[[NSString alloc] initWithData:ctx.task.currentRequest.HTTPBody encoding:NSUTF8StringEncoding];
        
        [LWUtils appendToLogFile:[NSString stringWithFormat:@"Authentication failed. Packet: %@\nRequest: %@", NSStringFromClass([pack class]), http]];
        [self.delegate authManagerDidNotAuthorized:self];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(authManager:didFailWithReject:context:)]) {
            
            [self.delegate authManager:self
                     didFailWithReject:pack.reject
                               context:ctx];
        }
    }
}


#pragma mark - Properties

- (BOOL)isAuthorized {
    return ([LWKeychainManager instance].token != nil);
}


#pragma mark - Static methods

+ (BOOL)isAuthneticationFailed:(NSURLResponse *)response {
    NSHTTPURLResponse* urlResponse = (NSHTTPURLResponse*)response;
    NSInteger const NotAuthenticated = 401;
    if (urlResponse && urlResponse.statusCode == NotAuthenticated) {
        return YES;
    }
    return NO;
}

+ (BOOL)isForbidden:(NSURLResponse *)response {
    NSHTTPURLResponse* urlResponse = (NSHTTPURLResponse*)response;
    NSInteger const NotAuthenticated = 403;
    if (urlResponse && urlResponse.statusCode == NotAuthenticated) {
        return YES;
    }
    return NO;
}

+ (BOOL)isNotOk:(NSURLResponse *)response {
    NSHTTPURLResponse* urlResponse = (NSHTTPURLResponse*)response;
    if (urlResponse && urlResponse.statusCode >= 400) {
        return YES;
    }
    return NO;
}

+ (BOOL)isInternalServerError:(NSURLResponse *)response {
    if([response isKindOfClass:[NSDictionary class]])
        return NO;
    NSHTTPURLResponse* urlResponse = (NSHTTPURLResponse*)response;
    NSInteger const InternalServerError = 500;
    if (urlResponse && urlResponse.statusCode == InternalServerError) {
        return YES;
    }
    return NO;
}

@end
