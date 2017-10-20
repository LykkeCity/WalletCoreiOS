//
//  LWTradeHistoryItemType.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 26.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBaseHistoryItemType.h"


@class LWTransactionTradeModel;
@class LWExchangeInfoModel;


@interface LWTradeHistoryItemType : LWBaseHistoryItemType {
    
}



@property (strong, nonatomic) LWExchangeInfoModel *marketOrder;

+ (LWTradeHistoryItemType *)convertFromNetworkModel:(LWTransactionTradeModel *)model;

@end
