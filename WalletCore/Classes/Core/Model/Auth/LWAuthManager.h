//
//  LWAuthManager.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 09.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWNetAccessor.h"
#import "LWRegistrationData.h"
#import "LWAuthenticationData.h"
#import "LWPacketKYCSendDocument.h"
#import "LWAuthSteps.h"




@class LWAuthManager;
@class LWLykkeWalletsData;
@class LWBankCardsAdd;
@class LWAssetModel;
@class LWPersonalData;
@class LWAssetPairModel;
@class LWAssetPairRateModel;
@class LWAppSettingsModel;
@class LWAssetDescriptionModel;
@class LWAssetDealModel;
@class LWAssetBlockchainModel;
@class LWTransactionsModel;
@class LWPersonalDataModel;
@class LWTransactionMarketOrderModel;
@class LWExchangeInfoModel;
@class LWPacketGraphPeriods;
@class LWPacketCountryCodes;
@class LWPacketGraphData;
@class LWGraphPeriodModel;
@class LWPacketCurrencyDeposit;
@class LWPacketCurrencyWithdraw;
@class LWPacketApplicationInfo;
@class LWPacketBitcoinAddressValidation;
@class LWPacketLastBaseAssets;
@class LWPacketKYCForAsset;
@class LWPacketGetRefundAddress;
@class LWPacketSetRefundAddress;
@class LWPacketAuthentication;
@class LWPacketPushSettingsGet;
@class LWPacketGetPaymentUrl;
@class LWPacketPrevCardPayment;
@class LWPacketGetHistory;
@class LWPacketClientKeys;
@class LWPrivateKeyOwnershipMessage;
@class LWRecoveryPasswordModel;
@class LWPacketAllAssetPairsRates;
@class LWPacketMyLykkeInfo;
@class LWPacketGetNews;
@class LWPacketSwiftCredentials;
@class LWPacketSwiftCredential;
@class LWPacketGetEthereumAddress;
@class LWWalletMigrationModel;
@class LWPacketOrderBook;
@class LWPacketKYCDocuments;
@class LWPacketCategories;
@class LWPacketGetPendingTransactions;
@class LWSignRequestModel;
@class LWPacketGetEthereumContract;
@class LWPacketMarketConverter;
@class LWPacketGetCrossbarUrl;
@class LWPacketGetBlockchainAddress;
@class LWWatchList;
@class LWPacketCheckIsUSAUser;
@class LWPacketCheckPendingActions;
@class LWPacketGetUnsignedSPOTTransactions;
@class LWPacketGetMainScreenInfo;
@class LWPacketMarginDepositWithdraw;
@class LWPacketAccountExist;


@protocol LWAuthManagerDelegate<NSObject>
@optional
- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context;
- (void)authManager:(LWAuthManager *)manager didCheckRegistration:(LWPacketAccountExist *) packet;
- (void)authManagerDidRegister:(LWAuthManager *)manager;
- (void)authManagerDidRegisterGet:(LWAuthManager *)manager KYCStatus:(NSString *)status isPinEntered:(BOOL)isPinEntered personalData:(LWPersonalData *)personalData;
- (void)authManagerDidAuthenticate:(LWAuthManager *)manager KYCStatus:(NSString *)status isPinEntered:(BOOL)isPinEntered;
- (void)authManager:(LWAuthManager *)manager didCheckDocumentsStatus:(LWDocumentsStatus *)status;
- (void)authManagerDidSendDocument:(LWAuthManager *)manager ofType:(KYCDocumentType)docType;
- (void)authManager:(LWAuthManager *)manager didGetKYCStatus:(NSString *)status personalData:(LWPersonalData *)personalData;
- (void)authManagerDidSetKYCStatus:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didValidatePin:(BOOL)isValid;
- (void)authManagerDidSetPin:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didReceiveRestrictedCountries:(NSArray *)countries;
- (void)authManager:(LWAuthManager *)manager didReceivePersonalData:(LWPersonalDataModel *)data;
- (void)authManager:(LWAuthManager *)manager didReceiveLykkeData:(LWLykkeWalletsData *)data;
- (void)authManagerDidNotAuthorized:(LWAuthManager *)manager;
- (void)authManagerDidCardAdd:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didGetBaseAssets:(NSArray *)assets;
- (void)authManager:(LWAuthManager *)manager didGetBaseAsset:(LWAssetModel *)asset;
- (void)authManagerDidSetAsset:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didGetAssetPair:(LWAssetPairModel *)assetPair;
- (void)authManager:(LWAuthManager *)manager didGetAssetPairs:(NSArray *)assetPairs;
- (void)authManager:(LWAuthManager *)manager didGetAssetPairRate:(LWAssetPairRateModel *)assetPairRate;
- (void)authManager:(LWAuthManager *)manager didGetAssetPairRates:(NSArray *)assetPairRates;
- (void)authManager:(LWAuthManager *)manager didGetAssetsDescriptions:(NSArray *)assetsDescriptions;
- (void)authManager:(LWAuthManager *)manager didGetAppSettings:(LWAppSettingsModel *)appSettings;
- (void)authManager:(LWAuthManager *)manager didReceiveDealResponse:(LWAssetDealModel *)purchase;
- (void)authManagerDidSetSignOrders:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didGetBlockchainTransaction:(LWAssetBlockchainModel *)blockchain;
- (void)authManager:(LWAuthManager *)manager didGetBlockchainCashTransaction:(LWAssetBlockchainModel *)blockchain;
- (void)authManager:(LWAuthManager *)manager didGetBlockchainExchangeTransaction:(LWAssetBlockchainModel *)blockchain;
- (void)authManager:(LWAuthManager *)manager didGetBlockchainTransferTransaction:(LWAssetBlockchainModel *)blockchain;
- (void)authManager:(LWAuthManager *)manager didReceiveTransactions:(LWTransactionsModel *)transactions;
- (void)authManager:(LWAuthManager *)manager didReceiveMarketOrder:(LWAssetDealModel *)marketOrder;
- (void)authManagerDidSendBlockchainEmail:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didReceiveExchangeInfo:(LWExchangeInfoModel *)exchangeInfo;
- (void)authManager:(LWAuthManager *)manager didReceiveAssetDicts:(NSArray *)assetDicts;
- (void)authManagerDidCashOut:(LWAuthManager *)manager;
- (void)authManagerDidTransfer:(LWAuthManager *)manager;
- (void)authManagerDidSendValidationEmail:(LWAuthManager *)manager;
- (void)authManagerDidCheckValidationEmail:(LWAuthManager *)manager passed:(BOOL)passed;
- (void)authManagerDidSendValidationPhone:(LWAuthManager *)manager;
- (void)authManagerDidCheckValidationPhone:(LWAuthManager *)manager passed:(BOOL)passed;
- (void)authManagerDidSetFullName:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didGetCountryCodes:(LWPacketCountryCodes *) countryCodes;
- (void)authManager:(LWAuthManager *)manager didGetGraphPeriods:(LWPacketGraphPeriods *) graphPeriods;
-(void) authManager:(LWAuthManager *)manager didGetGraphData:(LWPacketGraphData *)graphData;
-(void) authManager:(LWAuthManager *) manager didGetCurrencyDeposit:(LWPacketCurrencyDeposit *) deposit;

-(void) authManager:(LWAuthManager *) manager didSendWithdraw:(LWPacketCurrencyWithdraw *) withdraw;

-(void) authManager:(LWAuthManager *)manager didGetAPIVersion:(LWPacketApplicationInfo *) apiVersion;
-(void) authManager:(LWAuthManager *) manager didValidateBitcoinAddress:(LWPacketBitcoinAddressValidation *) bitconAddress;

-(void) authManager:(LWAuthManager *) manager didGetLastBaseAssets:(LWPacketLastBaseAssets *) lastAssets;

-(void) authManager:(LWAuthManager *) manager didGetAssetKYCStatusForAsset:(LWPacketKYCForAsset *) status;

-(void) authManager:(LWAuthManager *) manager didGetRefundAddress:(LWPacketGetRefundAddress *) address;
-(void) authManagerDidSetRefundAddress:(LWAuthManager *) manager;

-(void) authManager:(LWAuthManager *) manager didGetPushSettings:(LWPacketPushSettingsGet *) status;
-(void) authManagerDidSetPushSettings;

-(void) authManager:(LWAuthManager *)manager didGetPaymentUrl:(LWPacketGetPaymentUrl *) packet;

-(void) authManager:(LWAuthManager *)manager didGetLastCardPaymentData:(LWPacketPrevCardPayment *) packet;
-(void) authManager:(LWAuthManager *)manager didGetHistory:(LWPacketGetHistory *) packet;

-(void) authManagerDidSendClientKeys:(LWAuthManager *) manager;

-(void) authManager:(LWAuthManager *) manager didGetPrivateKeyOwnershipMessage:(LWPrivateKeyOwnershipMessage *) packet;
-(void) authManagerDidGetRecoverySMSConfirmation:(LWAuthManager *) manager;
-(void) authManagerDidChangePINAndPassword:(LWAuthManager *) manager;

-(void) authManager:(LWAuthManager *) manager didGetAllAssetPairsRate:(LWPacketAllAssetPairsRates *) packet;
-(void) authManager:(LWAuthManager *)manager didGetMyLykkeInfo:(LWPacketMyLykkeInfo *) packet;

-(void) authManagerDidSendMyLykkeCashInEmail:(LWAuthManager *)manager;
-(void) authManagerDidGetSwiftCredentials:(LWPacketSwiftCredentials *) packet;
-(void) authManagerDidGetSwiftCredential:(LWPacketSwiftCredential *) packet;

-(void) authManagerDidGetEthereumAddress:(LWPacketGetEthereumAddress *) ethereumAddress;

-(void) authManagerDidGetEncodedPrivateKey:(LWAuthManager *) manager;
-(void) authManagerDidSendEmailHint:(LWAuthManager *) manager;

-(void) authManagerDidRequestVoiceCall:(LWAuthManager *) manager;
-(void) authManagerDidCompleteWalletMigration:(LWAuthManager *) manager;

-(void) authManager:(LWAuthManager *)manager didGetOrderBook:(LWPacketOrderBook *)packet;
-(void) authManager:(LWAuthManager *)manager didGetKYCDocuments:(LWPacketKYCDocuments *)packet;

-(void) authManager:(LWAuthManager *) manager didGetAssetCategories:(LWPacketCategories *) packet;

-(void) authManager:(LWAuthManager *)manager didGetEthereumContract:(LWPacketGetEthereumContract *) packet;

-(void) authManagerDidSendEmailPrivateWalletAddress:(LWAuthManager *) manager;

-(void) authManagerDidGetMarketConverter:(LWPacketMarketConverter *) packet;
-(void) authManagerDidSendSolarCoinEmail:(LWAuthManager *) manager;
-(void) authManager:(LWAuthManager *) manager  didGetMarginalAccounts:(NSArray *) accounts;
    
-(void) authManager:(LWAuthManager *) manager didGetAllAssetPairs:(NSArray *) assetPairs;

-(void) authManager:(LWAuthManager *) manager didGetCrossbarUrl:(LWPacketGetCrossbarUrl *) packet;

-(void) authManagerDidGetCFDWatchLists:(LWAuthManager *) manager;
-(void) authManagerDidGetSpotWatchLists:(LWAuthManager *) manager;

-(void) authManagerDidGetBlockchainAddress:(LWPacketGetBlockchainAddress *) packet;

-(void) authManagerDidSendSettleRequest;

-(void) authManagerDidCheckIsUSANumber: (LWPacketCheckIsUSAUser *) packet;

-(void) authManagerDidGetAllAssets;

-(void) authManagerDidCheckPendingActions:(LWPacketCheckPendingActions *) packet;

-(void) authManagerDidGetUnsignedSPOTTransactions:(LWPacketGetUnsignedSPOTTransactions *) packet;

-(void) authManagerDidGetMainScreenInfo:(LWPacketGetMainScreenInfo *) packet;
-(void) authManagerDidSetMarginTermsStatus;
-(void) authManagerDidSendMarginDepositWithdraw:(LWPacketMarginDepositWithdraw *) pack;

@end


@interface LWAuthManager : LWNetAccessor {
    
}


@property (weak, nonatomic) id<LWAuthManagerDelegate> delegate;

@property (readonly, nonatomic) BOOL               isAuthorized;
@property (readonly, nonatomic) LWRegistrationData *registrationData;
@property (readonly, nonatomic) LWDocumentsStatus  *documentsStatus;

#pragma mark - Common
+ (LWAuthManager*)instance;
+ (LWAuthManager*)newInstance;
- (void)requestEmailValidation:(NSString *)email;
- (void)requestAuthentication:(LWAuthenticationData *)data;
- (void)requestRegistration:(LWRegistrationData *)data;
- (void)requestRegistrationGet;
- (void)requestDocumentsToUpload;
- (void)requestSendDocument:(KYCDocumentType)docType image:(UIImage *)image;
- (void)requestSendDocumentBin:(KYCDocumentType)docType image:(UIImage *)image;
- (void)requestKYCStatusGet;
- (void)requestKYCStatusSet;
- (void)requestPinSecurityGet:(NSString *)pin;
- (void)requestPinSecuritySet:(NSString *)pin;
- (void)requestRestrictedCountries;
- (void)requestPersonalData;
- (void)requestLykkeWallets;
- (void)requestSendLog:(NSString *)log;
- (void)requestAddBankCard:(LWBankCardsAdd *)card;
- (void)requestBaseAssets;
-(void) requestAllAssets;
- (void)requestBaseAssetGet;
- (void)requestBaseAssetSet:(NSString *)assetId;
-(void) requestLastBaseAssets;
- (void)requestAssetPair:(NSString *)pairId;
- (void)requestAssetPairs;
- (void)requestAssetPairRate:(NSString *)pairId;
- (void)requestAssetPairRates;
-(void) requestAssetPairRatesNoBaseAsset;
- (void)requestAssetsDescriptions:(NSArray *)assetIds;
- (void)requestAppSettings;
- (void)requestBuySellAsset:(NSString *)asset assetPair:(NSString *)assetPair volume:(NSNumber *)volume rate:(NSString *)rate;
- (void)requestSignOrders:(BOOL)shouldSignOrders;
- (void)requestBlockchainOrderTransaction:(NSString *)orderId;
- (void)requestBlockchainCashTransaction:(NSString *)cashOperationId;
- (void)requestBlockchainExchangeTransaction:(NSString *)exchnageOperationId;
- (void)requestBlockchainTransferTrnasaction:(NSString *)transferOperationId;
- (void)requestTransactions:(NSString *)assetId;

-(void) requestMarketConverter:(NSDictionary *)assetsDict lkkAssetId:(NSString *) lkkAssetId;

- (void)requestEmailBlockchainForAssetId:(NSString *) assetId address:(NSString *) address;
- (void)requestExchangeInfo:(NSString *)exchangeId;
- (void)requestDictionaries;
- (void)requestCashOut:(NSNumber *)amount assetId:(NSString *)assetId multiSig:(NSString *)multiSig;
- (void)requestTransfer:(NSString *)assetId amount:(NSNumber *)amount recipient:(NSString *)recepientId;
- (void)requestVerificationEmail:(NSString *)email;
- (void)requestVerificationEmail:(NSString *)email forCode:(NSString *)code;
- (void)requestVerificationPhone:(NSString *)phone;
- (void)requestVerificationPhone:(NSString *)phone forCode:(NSString *)code;
- (void)requestSetFullName:(NSString *)fullName;
- (void)requestCountyCodes;

-(void) requestGraphPeriods;
-(void) requestGraphDataForPeriod:(LWGraphPeriodModel *) period assetPairId:(NSString *) assetPairId points:(int) points;
-(void) requestCurrencyDepositForAsset:(NSString *) assetId changeValue:(NSNumber *) changeValue;
-(void) requestCurrencyWithdraw:(LWPacketCurrencyWithdraw *) withdraw;

-(void) requestAPIVersion;
-(void) validateBitcoinAddress:(NSString *) address;

-(void) requestSetReverted:(BOOL) reverted  assetPairId:(NSString *) assetPairId;

-(void) requestKYCStatusForAsset:(NSString *)assetId;

-(void) requestGetRefundAddress;
-(void) requestSetRefundAddress:(NSDictionary *) dict;

-(void) requestGetPushSettings;
-(void) requestSetPushEnabled:(BOOL) isEnabled;

-(void) requestEncodedPrivateKey;
-(void) requestSaveClientKeysWithPubKey:(NSString *) pubKey encodedPrivateKey:(NSString *) encodedPrivateKey;

-(void) requestGetPaymentUrlWithParameters:(NSDictionary *) params;

-(void) requestPrevCardPayment;

-(void) requestGetHistory:(NSString *) assetId;

-(void) requestPrivateKeyOwnershipMessage:(NSString *) email;
-(void) requestCheckPrivateKeyOwnershipMessageSignature:(NSString *) signature email:(NSString *) email;

-(void) requestRecoverySMSConfirmation:(LWRecoveryPasswordModel *) recModel;

-(void) requestChangePINAndPassword:(LWRecoveryPasswordModel *) recModel;

-(void) requestAllAssetPairsRates:(NSString *) assetId;

-(void) requestMyLykkeInfo;

//-(void) requestAllAssetPairs;

-(void) requestLykkeNewsWithCompletion:(void(^)(NSArray *)) completion;

-(void) requestSendMyLykkeCashInEmail:(NSDictionary *) params;

-(void) requestSwiftCredentials __attribute((deprecated("use requestSwiftCredential:assetId method")));
    
-(void) requestSwiftCredential:(NSString *) assetId;

-(void) requestEthereumAddress;

-(void) requestMyLykkeSettings;

-(void) requestSendHintForEmail:(NSString *) email;

-(void) requestSaveBackupState;

-(void) requestVoiceCall:(NSString *) phone email:(NSString *) email;

-(void) requestWalletMigration:(LWWalletMigrationModel *) migration;
-(void) requestSetPasswordHash:(NSString *) hash;

-(void) requestOrderBook:(NSString *) assetPairId;
-(void) requestKYCDocuments;

-(void) requestAssetCategories;

-(void) requestPendingTransactions;
-(void) requestSendSignedTransaction:(LWSignRequestModel *) signRequest;

-(void) requestEthereumContractForAddress:(NSString *) address pubKey:(NSString *) pubKey;

-(void) requestSendEmailPrivateWalletsAddress:(NSString *) address name:(NSString *) name;

- (void)requestMarketOrder:(NSString *)orderId;

-(void) requestSendSolarCoinAddressEmail:(NSString *) address;

-(void) requestIssuers;

-(void) requestMarginalAccounts;

-(void) requestCrossbarUrl;

-(void) requestLogout;

-(void) requestCFDWatchLists;
-(void) requestSpotWatchLists;

-(void) requestSaveWatchList:(LWWatchList *) watchList;
-(void) requestDeleteWatchList:(LWWatchList *) watchList;

-(void) requestBlockchainAddressForAssetId:(NSString *) assetId;

-(void) requestSettleForwardWithdrawForAsset: (LWAssetModel *) asset amount:(double) amount;

-(void) requestCheckIsUSAUser:(NSString *) phone;

-(void) requestSetUSAUser:(BOOL) flag;

-(void) requestCheckPendingActions;
-(void) requestGetUnsignedSPOTTransactions;
-(void) requestSendSignedSPOTTransactions:(NSArray *) transactions;

-(void) requestMainScreenInfo;
-(void) requestMainScreenInfo: (NSString *) assetId;

-(void) requestGetMarginTermsStatus;
-(void) requestSetMarginTermsStatus;

-(void) requestMarginalDepositWithdrawForAccountId:(NSString *) accountId amount: (NSNumber *) amount;
-(void) requestResetDemoMarginAccount:(NSString *) accountId;

//PubkeyAddressValidation

#pragma mark - Static methods

+ (BOOL)isAuthneticationFailed:(NSURLResponse *)response;
+ (BOOL)isForbidden:(NSURLResponse *)response;
+ (BOOL)isNotOk:(NSURLResponse *)response;
+ (BOOL)isInternalServerError:(NSURLResponse *)response;

@end
