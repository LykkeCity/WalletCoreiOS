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

@implementation LWHistoryManager



+(NSArray *) convertHistoryToArrayOfArrays:(NSArray *) history
{
    NSMutableArray *result=[[NSMutableArray alloc] init];
    
    NSMutableArray *similar=[[NSMutableArray alloc] init];
    
    for(NSDictionary *d in history)
    {
        id item;
        if(d[@"Trade"])
        {
            LWTransactionTradeModel *m=[[LWTransactionTradeModel alloc] initWithJSON:d[@"Trade"]];
//            if(!result[m.dateTime])
//                result[m.dateTime]=[[NSMutableArray alloc] init];
            item = [LWTradeHistoryItemType convertFromNetworkModel:m];
            [(LWTradeHistoryItemType *)item setMarketOrder:[[LWExchangeInfoModel alloc] initWithJSON:d[@"Trade"][@"MarketOrder"]]];
//            [result[m.dateTime] addObject:item];
        }
        else if(d[@"CashInOut"])
        {
            LWTransactionCashInOutModel *m=[[LWTransactionCashInOutModel alloc] initWithJSON:d[@"CashInOut"]];
//            if(!result[m.dateTime])
//                result[m.dateTime]=[[NSMutableArray alloc] init];
            item = [LWCashInOutHistoryItemType convertFromNetworkModel:m];
//            [result[m.dateTime] addObject:item];
        }
        else if(d[@"Transfer"])
        {
            LWTransactionTransferModel *m=[[LWTransactionTransferModel alloc] initWithJSON:d[@"Transfer"]];
//            if(!result[m.dateTime])
//                result[m.dateTime]=[[NSMutableArray alloc] init];
            item = [LWTransferHistoryItemType convertFromNetworkModel:m];
//            [result[m.dateTime] addObject:item];
        }
        
        if(!item)
            continue;
        
        if(similar.count==0 || [similar.lastObject isKindOfClass:[item class]])
        {
            [similar addObject:item];
        }
        else
        {
            [result addObject:similar];
            similar=[[NSMutableArray alloc] init];
            [similar addObject:item];
        }
        

    }
    if(similar.count)
        [result addObject:similar];
    
    return result;
}

+(NSArray *) prepareHistory:(NSArray *) operations marginal:(NSArray *) marginal {
    
    NSMutableArray *total = [[NSMutableArray alloc] init];
    
    for(NSDictionary *d in operations)
    {
        id item;
        if(d[@"Trade"])
        {
            LWTransactionTradeModel *m=[[LWTransactionTradeModel alloc] initWithJSON:d[@"Trade"]];
            item = [LWTradeHistoryItemType convertFromNetworkModel:m];
            [(LWTradeHistoryItemType *)item setMarketOrder:[[LWExchangeInfoModel alloc] initWithJSON:d[@"Trade"][@"MarketOrder"]]];
        }
        else if(d[@"CashInOut"])
        {
            LWTransactionCashInOutModel *m=[[LWTransactionCashInOutModel alloc] initWithJSON:d[@"CashInOut"]];
            if(m.isForwardSettlement) {
                item = [LWSettleHistoryItemType convertFromNetworkModel:m];
            }
            else {
                item = [LWCashInOutHistoryItemType convertFromNetworkModel:m];
            }
        }
        else if(d[@"Transfer"])
        {
            LWTransactionTransferModel *m=[[LWTransactionTransferModel alloc] initWithJSON:d[@"Transfer"]];
            item = [LWTransferHistoryItemType convertFromNetworkModel:m];
        }
        
        if(!item)
            continue;
        [total addObject:item];
    }
    
    [total addObjectsFromArray:marginal];
    
    NSArray *sorted = [total sortedArrayUsingComparator:
                           ^(LWTransactionTradeModel *d1, LWTransactionTradeModel *d2) {
                               return [d2.dateTime compare:d1.dateTime];
                           }];

    NSMutableArray *arrOfArrays = [[NSMutableArray alloc] init];
    NSMutableArray *similar;
    id prev = nil;
    for(id item in sorted) {
        if([item isKindOfClass:[prev class]] == false) {
            if(similar.count) {
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
    if(similar.count) {
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

@end
