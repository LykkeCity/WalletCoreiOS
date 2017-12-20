//
//  LWMWHistoryPosition.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/01/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWMWHistoryPosition.h"
#import "LWMarginalWalletsDataManager.h"
#import "LWMWHistoryElement.h"
#import "LWCache.h"
#import "LWMWHistoryTransferElement.h"
#import "LWMWHistoryPositionElement.h"

@interface LWMWHistoryPosition()
{
    int type;
}

@end

@implementation LWMWHistoryPosition

-(id) initWithPosition:(NSDictionary *) dict {
    self = [super init];
    type = 0;
    NSDictionary *d=[self removeNulls:dict];
    
    _accountId = d[@"AccountId"];
    _assetId = d[@"Instrument"];
    
    _openPrice=[d[@"OpenPrice"] doubleValue];
    _marketPNL = [d[@"PnL"] doubleValue];
    
    _interestRateSwapPNL = -[d[@"InterestRateSwap"] doubleValue];
    _totalPNL = [d[@"TotalPnL"] doubleValue];
    _comission = [d[@"OpenCommission"] doubleValue] + [d[@"CloseCommission"] doubleValue];
    
    _volume = [d[@"Volume"] doubleValue];
    
    _closePrice = [d[@"ClosePrice"] doubleValue];
    
    
    if(d[@"AssetAccuracy"]) {
        _accuracy = [d[@"AssetAccuracy"] intValue];
    }
    else {
        for(LWMarginalWalletAsset *asset in [LWMarginalWalletsDataManager shared].assets) {
            if([asset.identity isEqualToString:_assetId]) {
                _accuracy = asset.accuracy;
                break;
            }
        }
    }
    _stopLoss = [d[@"StopLoss"] doubleValue];
    _takeProfit = [d[@"TakeProfit"] doubleValue];
    
    
    NSInteger reason = [d[@"CloseReason"] intValue];
    _closeReason = reason;
    
    _openDate = [self dateFromString:d[@"OpenDate"]];
    _closeDate = [self dateFromString:d[@"CloseDate"]];
    if(!_openDate)
        return nil;
    _currencySymbol = @"";
    for(LWMarginalAccount *acc in [LWMarginalWalletsDataManager shared].accounts) {
        if([acc.identity isEqualToString:_accountId]) {
            _currencySymbol = [LWCache displayIdForAssetId:acc.baseAssetId];
            break;
        }
    }

    
    return self;
}

-(id) initWithTransfer:(NSDictionary *) dict {
    self = [super init];
    NSDictionary *d=[self removeNulls:dict];
    
    _accountId = d[@"AccountId"];
    _volume = [d[@"Amount"] doubleValue];
    type = [d[@"Type"] intValue] + 1;
    _openDate = [self dateFromString:d[@"Date"]];
    
    _currencySymbol = @"";
    _accuracy = 2;
    for(LWMarginalAccount *acc in [LWMarginalWalletsDataManager shared].accounts) {
        if([acc.identity isEqualToString:_accountId]) {
            _currencySymbol = [LWCache displayIdForAssetId:acc.baseAssetId];
            _accuracy = [LWCache accuracyForAssetId:acc.baseAssetId];
            break;
        }
    }

    
    return self;
}

-(NSArray *) elements
{
    if(type > 0) {
        LWMWHistoryTransferElement *element=[LWMWHistoryTransferElement new];
        element.dateTime = _openDate;
        element.volume = _volume;
        element.accountId = _accountId;
        if(type == 1) {
            element.type = DEPOSIT;
        }
        else {
            element.type = WITHDRAW;
        }
        element.currencySymbol = _currencySymbol;
        element.accuracy = _accuracy;
        return @[element];
        
    }
    
    LWMWHistoryPositionElement *open=[LWMWHistoryPositionElement new];
    [self fillFields:open];
    open.type = OPEN;
    open.dateTime = _openDate;
    if(!_closeDate) {
        return @[open];
    }
    LWMWHistoryPositionElement *close=[LWMWHistoryPositionElement new];
    [self fillFields:close];
    close.type = CLOSE;
    close.dateTime = _closeDate;
    return @[open, close];
}

-(void) fillFields:(LWMWHistoryElement *) element
{
    element.accountId = _accountId;
    element.assetId = _assetId;
    element.openDate = _openDate;
    element.openPrice = _openPrice;
    element.volume = _volume;
    element.closeDate = _closeDate;
    element.totalPNL = _totalPNL;
    
    element.marketPNL = _marketPNL;
    element.comission = _comission;
    element.interestRateSwapPNL = _interestRateSwapPNL;
    
    element.closeReason = _closeReason;

    element.closePrice = _closePrice;
    element.accuracy = _accuracy;
    element.stopLoss = _stopLoss;
    element.takeProfit = _takeProfit;
    
    element.currencySymbol = _currencySymbol;
}



@end
