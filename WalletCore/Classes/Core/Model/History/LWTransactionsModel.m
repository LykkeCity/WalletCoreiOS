//
//  LWTransactionsModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTransactionsModel.h"
#import "LWTransactionCashInOutModel.h"
#import "LWTransactionTradeModel.h"
#import "LWTransactionTransferModel.h"


@implementation LWTransactionsModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {

        // trades
        NSMutableArray *trades = [NSMutableArray new];
        for (NSDictionary *item in json[@"Trades"]) {
            [trades addObject:[[LWTransactionTradeModel alloc] initWithJSON:item]];
        }
        _trades = trades;
        
        // cash in / out
        NSMutableArray *cash = [NSMutableArray new];
        for (NSDictionary *item in json[@"CashInOut"]) {
            [cash addObject:[[LWTransactionCashInOutModel alloc] initWithJSON:item]];
        }
        _cashInOut = cash;
        

        // transfers
        NSMutableArray *transfers = [NSMutableArray new];
        for (NSDictionary *item in json[@"Transfers"]) {
            [transfers addObject:[[LWTransactionTransferModel alloc] initWithJSON:item]];
        }
        _transfers = transfers;

    }
    return self;
}

@end
