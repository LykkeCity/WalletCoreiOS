//
//  LWTransactionTradeModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 26.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTransactionTradeModel.h"
#import "NSString+Date.h"


@implementation LWTransactionTradeModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        NSString *date = [json objectForKey:@"DateTime"];

        _identity = [json objectForKey:@"Id"];
        _dateTime = [date toDate];
        _volume   = [json objectForKey:@"Volume"];
        _asset    = [json objectForKey:@"Asset"];
		_orderId  = [json objectForKey:@"OrderId"];
        _iconId   = [json objectForKey:@"IconId"];
        _blockchainHash=[json objectForKey:@"BlockChainHash"];
        _addressFrom=json[@"AddressFrom"];
        _addressTo=json[@"AddressTo"];
//        _isSettled=[json[@"IsSettled"] boolValue];    //removed with introdiction of offchain
        
        _isOffchain = [json[@"State"] isEqualToString:@"InProcessOffchain"] || [json[@"State"] isEqualToString:@"SettledOffchain"];
        _isSettled = [json[@"State"] isEqualToString:@"SettledOnchain"] || [json[@"State"] isEqualToString:@"SettledOffchain"];
		_isLimitTrade = [json[@"IsLimitTrade"] boolValue];
        
    }
    return self;
}

@end
