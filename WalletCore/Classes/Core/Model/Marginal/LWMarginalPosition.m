//
//  LWMarginalPosition.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 23/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMarginalPosition.h"
#import "LWMarginalWalletsDataManager.h"
#import "LWMarginalWalletAsset.h"
#import "LWMarginalWalletRate.h"
#import "LWMarginalAccount.h"
#import "NSString+Date.h"

@implementation LWMarginalPosition

-(id) init
{
    self=[super init];
    _stopLoss=0;
    _takeProfit=0;
    _price=0;
    _volume=0;
    
    return self;
}

-(id) initWithDict:(NSDictionary *) d
{
    self=[super init];
    
    [self updateWithDict:d];
    return self;
}

-(void) updateWithDict:(NSDictionary *) d
{
    _price=[d[@"OpenPrice"] doubleValue];
    _takeProfit=[d[@"TakeProfit"] doubleValue];
    _stopLoss=[d[@"StopLoss"] doubleValue];
    _accountId=d[@"AccountId"];
    _positionId=d[@"Id"];
    _assetPairId=d[@"Instrument"];
    
    if(d[@"OpenDate"]) {
        _openDate = [d[@"OpenDate"] toDate];
    }
    
    _closeReason = [d[@"CloseReason"] intValue];
    
    if([d[@"Type"] intValue]==1)
    {
        _flagShort=YES;
    }
    else
        _flagShort=NO;
    
//    if([d[@"ExpectedOpenPrice"] doubleValue] > 0) {
        _limitOrderOpenPrice = @([d[@"ExpectedOpenPrice"] doubleValue]);
//    }
    
    if([d[@"Status"] intValue] == 0) {
        _orderType = LIMIT_ORDER;
        _status = STATUS_WAITING;
    }
    else if([d[@"Status"] intValue] == 1) {
        _orderType = POSITION;
//        _limitOrderOpenPrice = nil;
        _status = STATUS_ACTIVE;
    }
    else {
        _status = STATUS_CLOSED;
    }
    
    _volume=fabs([d[@"Volume"] doubleValue]);
    
    for(LWMarginalAccount *acc in [LWMarginalWalletsDataManager shared].accounts)
    {
        if([acc.identity isEqualToString:_accountId])
        {
            _accountAssetId=acc.baseAssetId;
        }
    }

}

+(double) expectedPNLForAsset:(LWMarginalWalletAsset *) asset account:(LWMarginalAccount *) account volume:(double) volume limit:(double) limit isShort:(BOOL) flagShort fromPrice:(double) price position:(LWMarginalPosition *)position
{
    
    double moneyCur=limit*volume;
    
    double moneyBought;
    
    moneyBought=volume*price;
    
    if(position != nil) {
        moneyBought = position.price * position.volume;
    }

    
    double pnl=moneyCur-moneyBought;
    if(flagShort) {
        pnl = -pnl;
    }
    
    double finalPNL=0;
    if([asset.quotingAssetId isEqualToString:account.identity])
        finalPNL=pnl;
    else
    {
        for(LWMarginalWalletAsset *ass in [LWMarginalWalletsDataManager shared].assets)
        {
            if([ass.baseAssetId isEqualToString:account.baseAssetId] && [ass.quotingAssetId isEqualToString:asset.quotingAssetId])
            {
                finalPNL=pnl/ass.rate.ask;
                break;
            }
            if([ass.quotingAssetId isEqualToString:account.baseAssetId] && [ass.baseAssetId isEqualToString:asset.quotingAssetId])
            {
                finalPNL=pnl*ass.rate.bid;
                break;
            }
            
        }
    }
    return finalPNL;
}


-(double) marketPNL
{
    if(_orderType == LIMIT_ORDER) {
        return 0;
    }
    
    
    LWMarginalWalletAsset *asset = [self asset];

    
    double moneyBought=_price*_volume;
    LWMarginalWalletRate *rate=asset.rate;
    
    double moneyCur;
    if(_flagShort)
        moneyCur=_volume*rate.ask;
    else
        moneyCur=_volume*rate.bid;
    
//    NSLog(@"Asset: %@  %f/%f", asset.identity, rate.ask, rate.bid);
    
    
    double pnl=moneyCur-moneyBought;
    
    if(_flagShort)
        pnl=-pnl;
//    NSLog(@"Bought %f Cur %f PNL %f", moneyBought, moneyCur, pnl);

//    double finalPNL=0;
//    if([asset.quotingAssetId isEqualToString:_accountAssetId])
//        finalPNL=pnl;
//    else
//    {
//        for(LWMarginalWalletAsset *ass in assets)
//        {
////            NSLog(@"%@", ass.name);
//            if([ass.baseAssetId isEqualToString:_accountAssetId] && [ass.quotingAssetId isEqualToString:asset.quotingAssetId])
//            {
//                finalPNL=pnl/ass.rate.ask;
//                
////                NSLog(@"Asset: %@  %f/%f делим", ass.identity, ass.rate.ask, ass.rate.bid);
//
//                break;
//            }
//            if([ass.quotingAssetId isEqualToString:_accountAssetId] && [ass.baseAssetId isEqualToString:asset.quotingAssetId])
//            {
//                finalPNL=pnl*ass.rate.bid;
//                
////                NSLog(@"Asset: %@  %f/%f умножаем", ass.identity, ass.rate.ask, ass.rate.bid);
//
//                break;
//            }
//            
//        }
//    }
    
    double finalPNL = [self convertedToAccount:pnl];
    
//    NSLog(@"Итог PNL %f", finalPNL);
    
    
    return finalPNL;
}

-(double) pAndL {
    return [self swapPNL] + [self marketPNL];
}

-(double) swapPNL {
    if(_orderType == LIMIT_ORDER || _openDate == nil) {
        return 0;
    }

    LWMarginalWalletAsset *asset = [self asset];
    int seconds = [[NSDate date] timeIntervalSinceReferenceDate] - [_openDate timeIntervalSinceReferenceDate];
    double numberOfSecondsInYear = 60*60*24*365;
    double pnl;
    if(_flagShort) {
        pnl = ((asset.swapShort/numberOfSecondsInYear) * seconds) * _volume;
    }
    else {
        pnl = ((asset.swapLong/numberOfSecondsInYear) * seconds) * _volume;
    }
    
    return [self convertedToAccount:pnl];
}

-(double) convertedToAccount:(double) sum {
    if(sum == 0) {
        return 0;
    }
    LWMarginalWalletAsset *asset = [self asset];
    NSArray *assets=[LWMarginalWalletsDataManager shared].assets;

    double finalPNL=0;
    double pnl = sum;
    if([asset.quotingAssetId isEqualToString:_accountAssetId])
        finalPNL=pnl;
    else
    {
        for(LWMarginalWalletAsset *ass in assets)
        {
            //            NSLog(@"%@", ass.name);
            if([ass.baseAssetId isEqualToString:_accountAssetId] && [ass.quotingAssetId isEqualToString:asset.quotingAssetId])
            {
                finalPNL=pnl/ass.rate.ask;
                
                //                NSLog(@"Asset: %@  %f/%f делим", ass.identity, ass.rate.ask, ass.rate.bid);
                
                break;
            }
            if([ass.quotingAssetId isEqualToString:_accountAssetId] && [ass.baseAssetId isEqualToString:asset.quotingAssetId])
            {
                finalPNL=pnl*ass.rate.bid;
                
                //                NSLog(@"Asset: %@  %f/%f умножаем", ass.identity, ass.rate.ask, ass.rate.bid);
                
                break;
            }
            
        }
    }
    
    //    NSLog(@"Итог PNL %f", finalPNL);
    
    
    return finalPNL;

}


-(void) setPAndL:(double)pAndL
{
    return;
}

-(double) marginWithLeverage:(double) leverage
{
    NSArray *assets=[LWMarginalWalletsDataManager shared].assets;

    LWMarginalWalletAsset *asset = [self asset];
    double marginDirty=_volume/leverage;
    
    
    double margin=0;
    if([asset.baseAssetId isEqualToString:_accountAssetId])
        margin=marginDirty;
    else
    {
        for(LWMarginalWalletAsset *ass in assets)
        {
            if([ass.baseAssetId isEqualToString:_accountAssetId] && [ass.quotingAssetId isEqualToString:asset.baseAssetId])
            {
                margin=marginDirty/ass.rate.ask;
                break;
            }
            if([ass.quotingAssetId isEqualToString:_accountAssetId] && [ass.baseAssetId isEqualToString:asset.baseAssetId])
            {
                margin=marginDirty*ass.rate.bid;
                break;
            }
            
        }
    }
    
    return margin;
    
}

-(LWMarginalWalletAsset *) asset {
    NSArray *assets=[LWMarginalWalletsDataManager shared].assets;
    LWMarginalWalletAsset *asset;
    for(LWMarginalWalletAsset *ass in assets)
    {
        if([_assetPairId isEqualToString:ass.identity])
        {
            asset=ass;
            break;
        }
    }
    return asset;
}

-(double) marginLowLeverage {
    LWMarginalWalletAsset *asset = [self asset];
    return [self marginWithLeverage:asset.leverage];
}

-(double) margin {
    LWMarginalWalletAsset *asset = [self asset];
    return [self marginWithLeverage:asset.leveragHigher];

}

-(LWMarginalWalletRate *) currentRate
{
    NSArray *assets=[LWMarginalWalletsDataManager shared].assets;
    
    for(LWMarginalWalletAsset *ass in assets)
    {
        if([_assetPairId isEqualToString:ass.identity])
        {
            return ass.rate;
        }
    }
    return nil;
}

-(LWMarginalAccount *) account {
    
    for(LWMarginalAccount *a in [LWMarginalWalletsDataManager shared].accounts) {
        if([a.identity isEqualToString:_accountId]) {
            return a;
        }
    }
    return nil;
}




@end
