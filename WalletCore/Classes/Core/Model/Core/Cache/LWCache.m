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

#define SMS_DELAY 59

@implementation LWCache


#pragma mark - Root

SINGLETON_INIT {
    self = [super init];
    if (self) {
        // initial values
        
        _pushNotificationsStatus=PushNotificationsStatusUnknown;
        _refreshTimer = [NSNumber numberWithInteger:5000];
        _debugMode    = NO;
        self.cachedAssetPairsRates=[[NSMutableDictionary alloc] init];
        _cachedBuyOrders=[[NSMutableDictionary alloc] init];
        _cachedSellOrders=[[NSMutableDictionary alloc] init];
        self.showMyLykkeTab=NO;
        
        _smsRetriesLeft=3;

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logPacketHeaders:) name:@"PacketHeadersToLog" object:nil];
    }
    return self;
}

-(void) setIsUserFromUSA:(BOOL)isUserFromUSA {
    [[NSUserDefaults standardUserDefaults] setBool:isUserFromUSA forKey:@"TheUserIsFromUSA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL) isUserFromUSA {
//  return YES; //Testing
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"TheUserIsFromUSA"];
}

-(BOOL) flagShowMarginWallets {
//    return NO; //Testing
    
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShowMarginTrading"] boolValue];
}

-(BOOL) flagShowMarginWalletsLive {
    //@"ShowMarginTradingLive"
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShowMarginTradingLive"] boolValue];

}

-(BOOL) flagOffchainRequests {

    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"UseOffchainOperations"] boolValue];
}

-(BOOL) flagMarginTermsOfUseAgreed {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"MarginTermsOfUseAgreed"] boolValue];
}

-(void) setFlagMarginTermsOfUseAgreed:(BOOL)flagMarginTermsOfUseAgreed {
    [[NSUserDefaults standardUserDefaults] setObject:@(flagMarginTermsOfUseAgreed) forKey:@"MarginTermsOfUseAgreed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isMultisigAvailable {
    return (self.multiSig != nil
            && ![self.multiSig isKindOfClass:[NSNull class]]
            && ![self.multiSig isEqualToString:@""]);
}

+(BOOL) shouldHideDepositForAssetId:(NSString *)assetID
{
    BOOL shouldHide=YES;
    for(LWAssetModel *asset in [LWCache instance].allAssets)
    {
        if([asset.identity isEqualToString:assetID])
        {
            shouldHide = !(asset.visaDeposit || asset.swiftDeposit || asset.blockchainDeposit);
//            shouldHide=!((asset.bankCardDepositEnabled && [[NSUserDefaults standardUserDefaults] boolForKey:@"CanCashInViaBankCard"])
//                         ||
//                         (asset.swiftDepositEnabled && [[NSUserDefaults standardUserDefaults] boolForKey:@"SwiftDepositEnabled"])
//                         ||
//                         asset.blockchainDepositEnabled
//                         );
            break;
        }
    }
    
    return shouldHide;

}


+(BOOL) shouldHideWithdrawForAssetId:(NSString *)assetID
{
    BOOL shouldHide=NO;
    for(LWAssetModel *asset in [LWCache instance].allAssets)
    {
        if([asset.identity isEqualToString:assetID])
        {
            shouldHide=asset.hideWithdraw;
            break;
        }
    }
    
    return shouldHide;

//    NSArray *arr=@[@"USD",@"EUR", @"CHF", @"GBP", @"BTC", @"LKK"];
//    return [arr containsObject:assetID];
}

+(BOOL) isBankCardDepositEnabledForAssetId:(NSString *)assetID
{
    for(LWAssetModel *asset in [LWCache instance].allAssets)
    {
        if([asset.identity isEqualToString:assetID])
        {
            return asset.bankCardDepositEnabled && [[NSUserDefaults standardUserDefaults] boolForKey:@"CanCashInViaBankCard"];
        }
    }
    return NO;

}

+(BOOL) isSwiftDepositEnabledForAssetId:(NSString *)assetID
{
    for(LWAssetModel *asset in [LWCache instance].allAssets)
    {
        if([asset.identity isEqualToString:assetID])
        {
            return asset.swiftDepositEnabled && [[NSUserDefaults standardUserDefaults] boolForKey:@"SwiftDepositEnabled"];
        }
    }
    return NO;
}

+(BOOL) isBlockchainDepositEnabledForAssetId:(NSString *) assetID
{
    for(LWAssetModel *asset in [LWCache instance].allAssets)
    {
        if([asset.identity isEqualToString:assetID])
        {
            return asset.blockchainDepositEnabled;
        }
    }
    return NO;

}

+(NSString *) currentAppVersion
{
    
    NSString *version= [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *buildNum=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if(version && buildNum)
    {
        return [NSString stringWithFormat:@"Version %@ (%@)", buildNum, version];
    }
    return nil;
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

+(NSString *) nameForAsset:(NSString *) assetId
{
    for(LWAssetModel *asset in [LWCache instance].allAssets)
    {
        if([asset.identity isEqualToString:assetId])
            return asset.name;
    }
    return @"";
}

+(BOOL) isBaseAsset:(NSString *) assetId
{
    BOOL flag=NO;
    for(LWAssetModel *asset in [LWCache instance].baseAssets)
    {
        if([asset.identity isEqualToString:assetId])
        {
            flag=YES;
            break;
        }
    }
    return flag;
}

-(NSString *) baseAssetSymbol
{
    return [self currencySymbolForAssetId:self.baseAssetId];
}

+(int) accuracyForAssetId:(NSString *)assetId
{
    for(LWAssetModel *asset in [LWCache instance].allAssets)
    {
        if([asset.identity isEqualToString:assetId])
            return asset.accuracy.intValue;
    }
    return 0;
}


-(void) startTimerForSMS
{
    _smsDelaySecondsLeft=SMS_DELAY;
    _timerSMS=[NSTimer timerWithTimeInterval:1 target:self selector:@selector(smsDelayTimerFired) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timerSMS forMode:NSDefaultRunLoopMode];
}

-(void) smsDelayTimerFired
{
    _smsDelaySecondsLeft--;
    if(_smsDelaySecondsLeft==0)
    {
        _smsRetriesLeft--;
        [_timerSMS invalidate];
        _timerSMS=nil;
        if([_smsDelayDelegate respondsToSelector:@selector(smsTimerFinished)])
        {
            [_smsDelayDelegate smsTimerFinished];
        }
    }
    else
    {
        if([_smsDelayDelegate respondsToSelector:@selector(smsTimerFired)])
        {
            [_smsDelayDelegate smsTimerFired];
        }

    }
}

-(void) logPacketHeaders:(NSNotification *) notification
{
    [LWUtils appendToLogFile:notification.object];
}

-(NSArray *) lastMarginalBaseAssets
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"LastMarginalBaseAssets"];
}

-(void) setLastMarginalBaseAssets:(NSArray *)lastMarginalBaseAssets
{
    [[NSUserDefaults standardUserDefaults] setObject:lastMarginalBaseAssets forKey:@"LastMarginalBaseAssets"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *) currentMarginalBaseAsset
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentMarginalBaseAsset"];
    
}

-(void) setCurrentMarginalBaseAsset:(NSString *)currentMarginalBaseAsset
{
    [[NSUserDefaults standardUserDefaults] setObject:currentMarginalBaseAsset forKey:@"CurrentMarginalBaseAsset"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSMutableArray *) marginalWatchLists
{
    return _marginalWatchLists;
    
    if(_marginalWatchLists)
        return _marginalWatchLists;
    
    
    NSArray *arr=[[NSUserDefaults standardUserDefaults] objectForKey:@"MarginalWatchLists"];
//    if(!arr)
//    {
//        
//        NSMutableArray *aaa=[[NSMutableArray alloc] init];
//        [aaa addObject:@{@"name":@"Forex", @"assets":@[@"EURUSD", @"BTCUSD", @"BTCLKK"], @"isSelected":@(YES)}];
//        [aaa addObject:@{@"name":@"Custom", @"assets":@[@"ETHLKK", @"BTCGBP", @"BTCEUR"], @"isSelected":@(NO)}];
//        arr=aaa;
//    }
    NSMutableArray *lists=[[NSMutableArray alloc] init];
    for(NSDictionary *d in arr)
    {
        LWWatchList *list=[[LWWatchList alloc] initWithDict:d type:CFD];
        [lists addObject:list];
    }
    _marginalWatchLists=lists;
    
    return _marginalWatchLists;
}

-(NSMutableArray *) spotWatchLists {
    return _spotWatchLists;
//    if(_spotWatchLists)
//        return _spotWatchLists;
//
//    NSArray *arr=[[NSUserDefaults standardUserDefaults] objectForKey:@"SpotWatchLists"];
//    BOOL flagNew = false;
//    if(!arr)
//    {
//        NSMutableArray *aaa=[[NSMutableArray alloc] init];
//        for(LWAssetModel *a in self.allAssetPairs) {
//            [aaa addObject:a.identity];
//        }
//        
////        [aaa addObject:@{@"name":@"Forex", @"assets":@[@"EURUSD", @"BTCUSD", @"BTCLKK"], @"isSelected":@(YES)}];
////        [aaa addObject:@{@"name":@"Custom", @"assets":@[@"ETHLKK", @"BTCGBP", @"BTCEUR"], @"isSelected":@(NO)}];
//        arr = @[@{@"Name": @"All assets", @"AssetIds": aaa, @"ReadOnly": @(YES), @"Id":@"SPOTDefaultAllAssetsWatchList"}];
//        flagNew = true;
//    }
//    NSMutableArray *lists=[[NSMutableArray alloc] init];
//    for(NSDictionary *d in arr)
//    {
//        LWWatchList *list=[[LWWatchList alloc] initWithDict:d type:SPOT];
//        [lists addObject:list];
//    }
//    _spotWatchLists=lists;
//    
//    if(flagNew)
//    {
//        LWWatchList *l = _spotWatchLists.firstObject;
//        l.isSelected = true;
//    }
//    
//    return _spotWatchLists;

}

-(void) saveWatchLists
{
//    if(_marginalWatchLists)
//    {
//        NSMutableArray *arr=[[NSMutableArray alloc] init];
//        
//        for(LWWatchList *list in _marginalWatchLists)
//        {
//            NSDictionary *dict=[list dictionary];
//            [arr addObject:dict];
//        }
//        [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"MarginalWatchLists"];
//    }
    
//    if(_spotWatchLists)
//    {
//        NSMutableArray *arr=[[NSMutableArray alloc] init];
//        
//        for(LWWatchList *list in _spotWatchLists)
//        {
//            NSDictionary *dict=[list dictionary];
//            [arr addObject:dict];
//        }
//        [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"SpotWatchLists"];
//    }
//
//    
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}

+(NSString *) displayIdForAssetId:(NSString *)assetId {
    for(LWAssetModel *m in [LWCache instance].allAssets) {
        if([m.identity isEqualToString:assetId]) {
            return m.displayId;
        }
    }
    return @"";
}

+(LWAssetModel *) assetById:(NSString *)assetId {
    for(LWAssetModel *m in [LWCache instance].allAssets) {
        if([m.identity isEqualToString:assetId]) {
            return m;
        }
    }
    return nil;
}


@end
