//
//  LWCache.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCache.h"
#import "LWAssetModel.h"
#import "LWUtils.h"
#import "LWWatchList.h"
#import "LWUserDefault.h"
#import "LWKeychainManager.h"
#import "LWLykkeData.h"
#import "LWSpotWallet.h"
#import "LWAssetPairModel.h"

static const NSTimeInterval kSMSDelay = 59.0;
static double kDefaultMarketOrderPriceDeviation = 10;

@implementation LWCache


#pragma mark - Root

SINGLETON_INIT {
  self = [super init];
  if (self) {
    // initial values
    
    self.pushNotificationsStatus = PushNotificationsStatusUnknown;
    self.refreshTimer = [NSNumber numberWithInteger:5000];
    self.debugMode = NO;
    self.cachedAssetPairsRates= [NSMutableDictionary new];
    self.cachedBuyOrders = [NSMutableDictionary new];
    self.cachedSellOrders = [NSMutableDictionary new];
    self.showMyLykkeTab = NO;
    self.marketCaps = [NSMutableDictionary new];
    
    self.smsRetriesLeft = 3;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logPacketHeaders:) name:@"PacketHeadersToLog" object:nil];
  }
  return self;
}

- (BOOL)isMultisigAvailable {
  return (self.multiSig != nil
          && ![self.multiSig isKindOfClass:[NSNull class]]
          && ![self.multiSig isEqualToString:@""]);
}

- (NSString *)ethereumAddress {
  for (LWAssetModel *asset in self.allAssets) {
    if ([asset.identity isEqualToString:self.etherAssetId]) {
      return asset.blockchainDepositAddress;
    }
  }
  return nil;
}

+ (BOOL)shouldHidePlusForAssetId:(NSString *)assetID {
	LWAssetModel *asset = [self assetById:assetID];
	return !(asset.visaDeposit || asset.swiftDeposit || asset.blockchainDeposit || asset.buyScreen);
}

+ (BOOL)shouldHideDepositForAssetId:(NSString *)assetID {
	LWAssetModel *asset = [self assetById:assetID];
	return !(asset.visaDeposit || asset.swiftDeposit || asset.blockchainDeposit);
}

+ (BOOL)shouldHideWithdrawForAssetId:(NSString *)assetID {
	return [self assetById:assetID].hideWithdraw;
}

+ (BOOL)isBankCardDepositEnabledForAssetId:(NSString *)assetID {
	LWAssetModel *asset = [self assetById:assetID];
	return asset.bankCardDepositEnabled && [LWKeychainManager instance].canCashInViaBankCard;
}

+ (BOOL)isSwiftDepositEnabledForAssetId:(NSString *)assetID {
	return [self assetById:assetID].swiftDepositEnabled && [[self instance] isSwiftDepositEnabled];
}

+ (BOOL)isBlockchainDepositEnabledForAssetId:(NSString *)assetID {
  for (LWAssetModel *asset in [LWCache instance].allAssets) {
    if ([asset.identity isEqualToString:assetID]) {
      return asset.blockchainDepositEnabled;
    }
  }
  return NO;
}

-(NSString *) currencySymbolForAssetId:(NSString *)assetId
{
//    NSDictionary *currencySymbols=@{@"USD":@"$",
//                                    @"EUR":@"€",
//                                    @"CHF":@"₣",
//                                    @"GBP":@"£",
//                                    @"JPY":@"¥",
//                                    @"BTC":@"BTC"};
    
    NSString *symbol;
    
//    for(LWAssetModel *asset in self.allAssets)
//    {
//        if([asset.identity isEqualToString:assetId])
//        {
//            symbol=asset.symbol;
//            break;
//        }
//    }
//
//    if(!symbol)
        symbol=[LWCache displayIdForAssetId:assetId];
    return symbol;
}

+ (NSString *)currentAppVersion {
  NSString *version= [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
  NSString *buildNum=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  if (version && buildNum) {
    return [NSString stringWithFormat:@"Version %@ (%@)", buildNum, version];
  }
  return nil;
}

+ (NSString *)nameForAsset:(NSString *)assetId {
  for (LWAssetModel *asset in [LWCache instance].allAssets) {
    if ([asset.identity isEqualToString:assetId]) {
      return asset.name;
    }
  }
  return @"";
}

+ (BOOL)isBaseAsset:(NSString *)assetId {
  for (LWAssetModel *asset in [LWCache instance].baseAssets) {
    if ([asset.identity isEqualToString:assetId]) {
      return YES;
    }
  }
  return NO;
}

- (NSString *)baseAssetSymbol {
  return [LWCache displayIdForAssetId:self.baseAssetId];
}

+ (int)accuracyForAssetId:(NSString *)assetId {
  for (LWAssetModel *asset in [LWCache instance].allAssets) {
    if ([asset.identity isEqualToString:assetId])
      return asset.accuracy.intValue;
  }
  return 0;
}

- (NSNumber *)marketOrderPriceDeviation {
  return _marketOrderPriceDeviation ?: @(kDefaultMarketOrderPriceDeviation);
}

- (void)startTimerForSMS {
  _smsDelaySecondsLeft = kSMSDelay;
  [self.timerSMS invalidate];
  self.timerSMS = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(smsDelayTimerFired) userInfo:nil repeats:YES];
  [[NSRunLoop currentRunLoop] addTimer:self.timerSMS forMode:NSDefaultRunLoopMode];
}

- (void)smsDelayTimerFired {
  _smsDelaySecondsLeft--;
  if(_smsDelaySecondsLeft <= 0) {
    _smsRetriesLeft--;
    [self.timerSMS invalidate];
    self.timerSMS = nil;
    if ([self.smsDelayDelegate respondsToSelector:@selector(smsTimerFinished)]) {
      [self.smsDelayDelegate smsTimerFinished];
    }
  } else {
    if ([self.smsDelayDelegate respondsToSelector:@selector(smsTimerFired)]) {
      [self.smsDelayDelegate smsTimerFired];
    }
  }
}

- (void)logPacketHeaders:(NSNotification *)notification {
  [LWUtils appendToLogFile:notification.object];
}

- (NSMutableArray *)marginalWatchLists {
  return _marginalWatchLists;
}

- (LWWatchList *)currentSpotWatchList {
  for (LWWatchList *list in self.spotWatchLists) {
    if (list.isSelected) {
      return list;
    }
  }
  return nil;
}

- (LWWatchList *)currentMarginWatchList {
  for (LWWatchList *list in self.marginalWatchLists) {
    if (list.isSelected) {
      return list;
    }
  }
  return nil;
}

+ (NSString *)displayIdForAssetId:(NSString *)assetId {
  for(LWAssetModel *m in [LWCache instance].allAssets) {
    if([m.identity isEqualToString:assetId]) {
      return m.displayId;
    }
  }
  return @"";
}

+ (LWAssetModel *)assetById:(NSString *)assetId {
  for(LWAssetModel *m in [LWCache instance].allAssets) {
    if([m.identity isEqualToString:assetId]) {
      return m;
    }
  }
  return nil;
}

+ (LWAssetModel *)assetByName:(NSString *)assetName {
    for(LWAssetModel *m in [LWCache instance].allAssets) {
        if([m.name isEqualToString:assetName] || [m.identity isEqualToString:assetName]) {
            return m;
        }
    }
    return nil;
}

+ (NSNumber *)accuracyForAssetWithId:(NSString *)identity {
  for (LWAssetModel *asset in [LWCache instance].allAssets) {
    if ([asset.identity isEqualToString:identity]) {
      return asset.accuracy;
    }
  }
  return @(0);
}

+ (LWSpotWallet *)walletForAssetId:(NSString *)assetId {
  for (LWSpotWallet *wallet in [LWCache instance].walletsData.wallets) {
    if ([wallet.asset.identity isEqualToString:assetId]) {
      return wallet;
    }
  }
  return nil;
}

+ (LWAssetPairModel *)assetPairById:(NSString *)assetPairId {
  for (LWAssetPairModel *pair in [LWCache instance].allAssetPairs) {
    if ([pair.identity isEqualToString:assetPairId]) {
      return pair;
    }
  }
  return nil;
}

+ (LWAssetPairModel *)assetPairForAssetId:(NSString *)assetId otherAssetId:(NSString *)otherAssetId {
	for (LWAssetPairModel *pair in [LWCache instance].allAssetPairs) {
		if (([pair.baseAssetId isEqualToString:assetId] && [pair.quotingAssetId isEqualToString:otherAssetId]) ||
			([pair.quotingAssetId isEqualToString:assetId] && [pair.baseAssetId isEqualToString:otherAssetId])) {
			return pair;
		}
	}
	return nil;
}

+ (void)logout {
  [[LWUserDefault instance] reset];
  [self reset];
}

@end
