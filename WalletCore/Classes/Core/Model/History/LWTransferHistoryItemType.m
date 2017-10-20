//
//  LWTransferHistoryItemType.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 12.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTransferHistoryItemType.h"
#import "LWTransactionTransferModel.h"


@implementation LWTransferHistoryItemType

+ (LWTransferHistoryItemType *)convertFromNetworkModel:(LWTransactionTransferModel *)model {
    LWTransferHistoryItemType *result = [LWTransferHistoryItemType new];
    result.dateTime    = model.dateTime;
    result.identity    = model.identity;
    result.volume      = model.volume;
    result.asset       = model.asset;
    result.assetId     = model.assetId;
    
    result.historyType = LWHistoryItemTypeTransfer;
    result.addressFrom=model.addressFrom;
    result.addressTo=model.addressTo;

    result.iconId=model.iconId;
    result.blockchainHash=model.blockchainHash;
    result.isSettled=model.isSettled;

    
    return result;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    LWTransferHistoryItemType* data = [super copyWithZone:zone];
    data.volume = [self.volume copy];
    data.iconId = [self.iconId copy];
    data.blockchainHash = [self.blockchainHash copy];
    return data;
}

@end
