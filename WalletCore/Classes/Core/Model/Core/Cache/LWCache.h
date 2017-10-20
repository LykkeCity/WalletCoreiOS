//
//  LWCache.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"


@class LWLykkeData;
@class LWPersonalDataModel;
@class  LWAssetModel;


typedef NS_ENUM(NSUInteger, PushNotificationsStatus) {
    PushNotificationsStatusUnknown=0,
    PushNotificationsStatusDisabled=1,
    PushNotificationsStatusEnabled=2
    
};

@interface LWCache : NSObject {
    
}

SINGLETON_DECLARE


#pragma mark - Properties

//@property BOOL userWatchedAllBackupWords;

@property (readonly) BOOL flagShowMarginWallets;
@property (readonly) BOOL flagShowMarginWalletsLive;
@property (readonly) BOOL flagOffchainRequests;


@property BOOL flagMarginTermsOfUseAgreed;

@property (strong, nonatomic) NSArray *allMarginalBaseAssets;
@property (strong, nonatomic) NSArray *lastMarginalBaseAssets;
@property (strong, nonatomic) NSString *currentMarginalBaseAsset;

@property (strong, nonatomic) NSMutableArray *marginalWatchLists;
@property (strong, nonatomic) NSMutableArray *spotWatchLists;


@property BOOL isUserFromUSA;
@property BOOL passwordIsHashed;

@property (strong, nonatomic) NSTimer *timerSMS;
@property (strong, nonatomic) id smsDelayDelegate;
@property int smsDelaySecondsLeft;
@property int smsRetriesLeft;

@property (strong, nonatomic) NSMutableDictionary *cachedBuyOrders;
@property (strong, nonatomic) NSMutableDictionary *cachedSellOrders;
@property (strong, nonatomic) NSMutableDictionary *cachedAssetPairsRates;
@property (strong, nonatomic) NSDictionary *swiftCredentialsDict;
@property (strong, nonatomic) NSString *supportPhoneNum;

@property (strong, nonatomic) NSDictionary *issuers;

@property PushNotificationsStatus pushNotificationsStatus;

@property BOOL showMyLykkeTab;

@property (copy, nonatomic) NSString *btcConversionWalletAddress;

@property (strong, nonatomic) NSString *informationBrochureUrl;

@property (strong, nonatomic) NSString *wampServerUrl;
@property (strong, nonatomic) NSString *marginalApiUrl;

@property (strong, nonatomic) NSString *termsOfUseUrl;
@property (strong, nonatomic) NSString *refundInfoUrl;
@property (strong, nonatomic) NSString *userAgreementUrl;

@property (strong, nonatomic) NSString *marginTermsOfUseUrl;
@property (strong, nonatomic) NSString *marginRiskDescriptionUrl;
@property (strong, nonatomic) NSString *spotTermsOfUseUrl;

@property (copy, nonatomic) NSNumber *refreshTimer;
@property (copy, nonatomic) NSString *baseAssetId;
@property (copy, nonatomic) NSString *baseAssetSymbol;
@property (copy, nonatomic) NSArray  *baseAssets; // Array of LWAssetModel items
@property (strong, nonatomic) NSArray *allAssetPairs;

@property (strong, nonatomic) NSArray *walletsCategories;
@property (strong, nonatomic) LWLykkeData *walletsData;

@property (strong, nonatomic) NSString *cashInVisaURL;
@property (strong, nonatomic) NSString *cashInVisaSuccessURL;
@property (strong, nonatomic) NSString *cashInVisaFailURL;

@property (strong, nonatomic) NSString *UrlsToFormatRegex;

@property (copy, nonatomic) NSArray *allAssets;

@property (copy, nonatomic) NSString *depositUrl;
@property (copy, nonatomic) NSString *multiSig;
@property (copy, nonatomic) NSString *coloredMultiSig;
@property (copy, nonatomic) NSString *solarCoinAddress;

@property (copy, nonatomic) NSString *refundAddress;
@property BOOL refundSendAutomatically;
@property int refundDaysValidAfter;

@property (copy, nonatomic) NSString *serverAPIVersion;

@property (strong, nonatomic) LWPersonalDataModel *lastCardPaymentData;

// Array of LWAssetsDictionaryItem items
@property (copy, nonatomic) NSArray  *assetsDict;
@property (assign, nonatomic) BOOL shouldSignOrder;
@property (assign, nonatomic) BOOL debugMode;

- (BOOL)isMultisigAvailable;

+(BOOL) shouldHideDepositForAssetId:(NSString *)assetID;
+(BOOL) shouldHideWithdrawForAssetId:(NSString *)assetID;

+(BOOL) isBankCardDepositEnabledForAssetId:(NSString *) assetID;
+(BOOL) isSwiftDepositEnabledForAssetId:(NSString *) assetID;
+(BOOL) isBlockchainDepositEnabledForAssetId:(NSString *) assetID;


+(BOOL) isBaseAsset:(NSString *) assetId;

+(NSString *) currentAppVersion;

-(NSString *) currencySymbolForAssetId:(NSString *) assetId;
+(NSString *) nameForAsset:(NSString *) assetId;
+(int) accuracyForAssetId:(NSString *) assetId;

-(void) startTimerForSMS;

-(void) saveWatchLists;

+(NSString *) displayIdForAssetId:(NSString *) assetId;

+(LWAssetModel *) assetById:(NSString *) assetId;


@end


@protocol SMSTimerDelegate

-(void) smsTimerFinished;
-(void) smsTimerFired;
@end
