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

typedef NS_ENUM(NSInteger, LWAccountConvertionType) {
  LWAccountConvertionTypeMarketPNL,
  LWAccountConvertionTypeSwap
};

@implementation LWMarginalPosition

- (instancetype)init {
  self=[super init];
  if (self) {
    self.stopLoss = 0;
    self.takeProfit = 0;
    self.price = 0;
    self.volume = 0;
  }
  return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self) {
    [self updateWithDictionary:dict];
  }
  return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict {
  self.price = [dict[@"OpenPrice"] doubleValue];
  self.takeProfit = [dict[@"TakeProfit"] doubleValue];
  self.stopLoss = [dict[@"StopLoss"] doubleValue];
  self.accountId = dict[@"AccountId"];
  self.positionId = dict[@"Id"];
  self.assetPairId = dict[@"Instrument"];
  self.limitOrderOpenPrice = @([dict[@"ExpectedOpenPrice"] doubleValue]);
  
  if(dict[@"OpenDate"] != nil) {
    self.openDate = [dict[@"OpenDate"] toDate];
  }
  
  _closeReason = [dict[@"CloseReason"] intValue];
  _shortPosition = [dict[@"Type"] intValue] != 0;
  
  switch ([dict[@"Status"] intValue]) {
    case 0:
      _orderType = LWOrderTypeLimit;
      _status = LWPositionStatusWaiting;
      break;
    case 1:
      _orderType = LWOrderTypePosition;
      _status = LWPositionStatusActive;
      break;
    default:
      _status = LWPositionStatusClosed;
      break;
  }
  
  self.volume = fabs([dict[@"Volume"] doubleValue]);
  
  for (LWMarginalAccount *acc in [LWMarginalWalletsDataManager shared].accounts) {
    if ([acc.identity isEqualToString:self.accountId]) {
      self.accountAssetId = acc.baseAssetId;
      break;
    }
  }
  
}

+ (double)expectedPNLForAsset:(LWMarginalWalletAsset *)asset account:(LWMarginalAccount *)account volume:(double)volume limit:(double)limit isShort:(BOOL)isShort fromPrice:(double)price position:(LWMarginalPosition *)position {
  
  double moneyCur = limit * volume;
  double moneyBought = 0;
  
  moneyBought = volume * price;
  
  if (position != nil) {
    if(position.orderType == LWOrderTypeLimit) {
      moneyBought = position.limitOrderOpenPrice.doubleValue * position.volume;
    } else {
      moneyBought = position.price * position.volume;
    }
  }
  
  double pnl = moneyCur - moneyBought;
  if (isShort) {
    pnl = -pnl;
  }
  
  double finalPNL = 0;
  if([asset.quotingAssetId isEqualToString:account.baseAssetId]) {
    finalPNL = pnl;
  } else {
    for(LWMarginalWalletAsset *ass in [LWMarginalWalletsDataManager shared].allAssets) {
      if([ass.baseAssetId isEqualToString:account.baseAssetId] && [ass.quotingAssetId isEqualToString:asset.quotingAssetId]) {
        finalPNL= pnl / ass.rate.ask;
        break;
      }
      if([ass.quotingAssetId isEqualToString:account.baseAssetId] && [ass.baseAssetId isEqualToString:asset.quotingAssetId]) {
        finalPNL = pnl * ass.rate.bid;
        break;
      }
    }
  }
  return finalPNL;
}

- (double)marketPNL {
  if(self.orderType == LWOrderTypeLimit) {
    return 0;
  }
  
  double moneyBought = _price*_volume;
  LWMarginalWalletRate *rate = [self asset].rate;
  
  double moneyCur;
  if ([self isShortPosition]) {
    moneyCur = self.volume * rate.ask;
  } else {
    moneyCur = self.volume * rate.bid;
  }
  
  double pnl = moneyCur - moneyBought;
  
  if ([self isShortPosition]) {
    pnl = -pnl;
  }
  
  return [self convertedToAccount:pnl convertionType:LWAccountConvertionTypeMarketPNL];
}

-(double) pAndL {
  return [self swapPNL] + [self marketPNL];
}

- (double)swapPNL {
  if(self.orderType == LWOrderTypeLimit || _openDate == nil) {
    return 0;
  }
  
  LWMarginalWalletAsset *asset = [self asset];
  int seconds = [[NSDate date] timeIntervalSinceReferenceDate] - [_openDate timeIntervalSinceReferenceDate];
  double numberOfSecondsInYear = 60*60*24*365;
  double pnl;
  if([self isShortPosition]) {
    pnl = ((asset.swapShort / numberOfSecondsInYear) * seconds) * self.volume;
  } else {
    pnl = ((asset.swapLong/numberOfSecondsInYear) * seconds) * self.volume;
  }
  
  return [self convertedToAccount:pnl convertionType:LWAccountConvertionTypeSwap];
}

- (double)convertedToAccount:(double)sum convertionType:(LWAccountConvertionType)convertionType {
  if(sum == 0) {
    return 0;
  }
  LWMarginalWalletAsset *asset = [self asset];
  NSArray *assets = [LWMarginalWalletsDataManager shared].allAssets;
  
  double finalPNL = 0;
  double pnl = sum;
  
  NSString *assetId = nil;
  switch (convertionType) {
    case LWAccountConvertionTypeSwap:
      assetId = asset.baseAssetId;
      break;
    default:
      assetId = asset.quotingAssetId;
      break;
  }
  
  if ([assetId isEqualToString:_accountAssetId]) {
    finalPNL = pnl;
  } else {
    for(LWMarginalWalletAsset *ass in assets) {
      if([ass.baseAssetId isEqualToString:_accountAssetId] &&
         [ass.quotingAssetId isEqualToString:asset.quotingAssetId]) {
        finalPNL=pnl / ass.rate.ask;
        break;
      }
      if([ass.quotingAssetId isEqualToString:_accountAssetId] &&
         [ass.baseAssetId isEqualToString:asset.quotingAssetId]) {
        finalPNL = pnl * ass.rate.bid;
        break;
      }
    }
  }
  
  return finalPNL;
}


- (void)setPAndL:(double)pAndL {
  return;
}

- (double)marginWithLeverage:(double)leverage {
  NSArray *assets = [LWMarginalWalletsDataManager shared].allAssets;
  
  LWMarginalWalletAsset *asset = [self asset];
  double marginDirty = self.volume / leverage;
  
  
  double margin = 0;
  if ([asset.baseAssetId isEqualToString:_accountAssetId]) {
    margin = marginDirty;
  } else {
    for(LWMarginalWalletAsset *ass in assets) {
      if([ass.baseAssetId isEqualToString:_accountAssetId] && [ass.quotingAssetId isEqualToString:asset.baseAssetId]) {
        margin=marginDirty/ass.rate.ask;
        break;
      }
      if([ass.quotingAssetId isEqualToString:_accountAssetId] && [ass.baseAssetId isEqualToString:asset.baseAssetId]) {
        margin=marginDirty*ass.rate.bid;
        break;
      }
    }
  }
  
  return margin;
}

- (LWMarginalWalletAsset *)asset {
  for (LWMarginalWalletAsset *asset in [LWMarginalWalletsDataManager shared].allAssets) {
    if([_assetPairId isEqualToString:asset.identity] &&
       [asset.account.identity isEqualToString:_accountId]) {
      return asset;
    }
  }
  return nil;
}

- (double)marginLowLeverage {
  LWMarginalWalletAsset *asset = [self asset];
  return [self marginWithLeverage:asset.leverage];
}

- (double)margin {
  return [self marginWithLeverage:[self asset].leveragHigher];
}

- (LWMarginalWalletRate *)currentRate {
  for(LWMarginalWalletAsset *ass in [LWMarginalWalletsDataManager shared].assets) {
    if([_assetPairId isEqualToString:ass.identity]) {
      return ass.rate;
    }
  }
  return nil;
}

- (LWMarginalAccount *)account {
  for(LWMarginalAccount *asset in [LWMarginalWalletsDataManager shared].accounts) {
    if([asset.identity isEqualToString:_accountId]) {
      return asset;
    }
  }
  return nil;
}

@end
