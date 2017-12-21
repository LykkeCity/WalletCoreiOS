//
//  LWHistoryManager.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWHistoryManager.h"
#import "LWTransactionsModel.h"
#import "LWTransactionCashInOutModel.h"
#import "LWTransactionTransferModel.h"
#import "LWTransactionTradeModel.h"
#import "LWTradeHistoryItemType.h"
#import "LWCashInOutHistoryItemType.h"
#import "LWTransferHistoryItemType.h"
#import "LWExchangeInfoModel.h"
#import "LWMWHistoryElement.h"
#import "LWSettleHistoryItemType.h"
#import "LWLimitHistoryItemType.h"
#import <BlocksKit/BlocksKit.h>

@implementation LWHistoryManager

static NSMutableArray *history;

+ (NSArray *)prepareLimitHistory:(NSArray *)operations {
	NSArray *history = [self prepareHistory:operations marginal:@[]];
	return history.count ? history[0] : @[];
}

+ (NSArray *)prepareHistory:(NSArray *)operations marginal:(NSArray *)marginal {
    
    NSMutableArray *total = [[NSMutableArray alloc] init];
    
    for (NSDictionary *d in operations) {
        id item;
		
		NSDictionary *tradeItem = d[@"Trade"];
		NSDictionary *cashInOutItem = d[@"CashInOut"];
		NSDictionary *transferItem = d[@"Transfer"];
		NSDictionary *limitItem = d[@"LimitTradeEvent"];
		
        if (tradeItem) {
            LWTransactionTradeModel *m = [[LWTransactionTradeModel alloc] initWithJSON:tradeItem];
            item = [LWTradeHistoryItemType convertFromNetworkModel:m];
            [(LWTradeHistoryItemType *)item setMarketOrder:[[LWExchangeInfoModel alloc] initWithJSON:tradeItem[@"MarketOrder"]]];
        }
        else if (cashInOutItem) {
            LWTransactionCashInOutModel *m = [[LWTransactionCashInOutModel alloc] initWithJSON:cashInOutItem];
            if (m.isForwardSettlement) {
                item = [LWSettleHistoryItemType convertFromNetworkModel:m];
            }
            else {
                item = [LWCashInOutHistoryItemType convertFromNetworkModel:m];
            }
        }
        else if (transferItem) {
            LWTransactionTransferModel *m = [[LWTransactionTransferModel alloc] initWithJSON:transferItem];
            item = [LWTransferHistoryItemType convertFromNetworkModel:m];
        }
		else if (limitItem) {
			item = [[LWLimitHistoryItemType alloc] initWithJson:limitItem];
		}
        
		if (!item) {
            continue;
		}
        [total addObject:item];
    }
    
    [total addObjectsFromArray:marginal];
	history = total.mutableCopy;
	
    NSArray *sorted = [total sortedArrayUsingComparator:
                           ^(LWTransactionTradeModel *d1, LWTransactionTradeModel *d2) {
                               return [d2.dateTime compare:d1.dateTime];
                           }];

    NSMutableArray *arrOfArrays = [[NSMutableArray alloc] init];
    NSMutableArray *similar;
    id prev = nil;
    for (id item in sorted) {
		BOOL isSameClass = [item isKindOfClass:[prev class]];
		
		BOOL(^isTradeLimit)(id) = ^BOOL(id item){
			return ([item isKindOfClass:[LWTradeHistoryItemType class]] && ((LWTradeHistoryItemType *)item).isLimitTrade)
				 || [item isKindOfClass:[LWLimitHistoryItemType class]];
		};
		
		BOOL isSame = isSameClass || (isTradeLimit(item) && isTradeLimit(prev));
		
        if (isSame == NO) {
            if (similar.count) {
                [arrOfArrays addObject:similar];
            }
            similar = [[NSMutableArray alloc] init];
            [similar addObject:item];
        }
        else {
            [similar addObject:item];
        }
        prev = item;
    }
    if (similar.count) {
        [arrOfArrays addObject:similar];
    }
    return arrOfArrays;
}


+ (NSArray *)sortKeys:(NSDictionary *)dictionary {
    // sorting
    NSArray *sortedKeys = [[dictionary allKeys] sortedArrayUsingComparator:
                           ^(NSDate *d1, NSDate *d2) {
                               return [d2 compare:d1];
                           }];
    return sortedKeys;
}

+ (NSArray *)historyForOrderId:(NSString *)orderId {
	return [history bk_select:^BOOL(LWTradeHistoryItemType *obj) {
		return [obj isKindOfClass:[LWTradeHistoryItemType class]] && [obj.orderId isEqualToString:orderId];
	}];
}

@end
