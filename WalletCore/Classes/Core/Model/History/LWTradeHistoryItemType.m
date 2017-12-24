//
//  LWTradeHistoryItemType.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 26.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTradeHistoryItemType.h"
#import "LWTransactionTradeModel.h"


@implementation LWTradeHistoryItemType

+ (LWTradeHistoryItemType *)convertFromNetworkModel:(LWTransactionTradeModel *)model {
    LWTradeHistoryItemType *result = [LWTradeHistoryItemType new];
    result.dateTime    = model.dateTime;
    result.identity    = model.identity;
    result.volume      = model.volume;
    
    result.asset       = model.asset;
    result.assetId     = model.assetId;
    result.historyType = LWHistoryItemTypeTrade;
    result.addressFrom=model.addressFrom;
    result.addressTo=model.addressTo;
    
    result.iconId=model.iconId;
    result.blockchainHash=model.blockchainHash;
    result.isSettled=model.isSettled;
    result.isOffchain = model.isOffchain;
    
    return result;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    LWTradeHistoryItemType* data = [super copyWithZone:zone];
    data.volume = [self.volume copy];
    data.iconId = [self.iconId copy];
    return data;
}

@end
