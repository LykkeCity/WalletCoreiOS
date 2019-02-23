//
//  LWTransactionCashInOutModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTransactionCashInOutModel.h"
#import "NSString+Date.h"


@implementation LWTransactionCashInOutModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _identity = [json objectForKey:@"Id"];
        _amount   = [json objectForKey:@"Amount"];
        NSString *date = [json objectForKey:@"DateTime"];
        _dateTime = [date toDate];
        _asset    = [json objectForKey:@"Asset"];
        _assetId    = [json objectForKey:@"AssetId"];
        _iconId   = [json objectForKey:@"IconId"];
        _blockchainHash=[json objectForKey:@"BlockChainHash"];
        _isRefund=[[json objectForKey:@"IsRefund"] boolValue];
        
        _addressFrom=json[@"AddressFrom"];
        _addressTo=json[@"AddressTo"];
//        _isSettled=[json[@"IsSettled"] boolValue];
        
        _isOffchain = [json[@"State"] isEqualToString:@"InProcessOffchain"] || [json[@"State"] isEqualToString:@"SettledOffchain"];
        _isSettled = [json[@"State"] isEqualToString:@"SettledOnchain"] || [json[@"State"] isEqualToString:@"SettledOffchain"];

        
        _isForwardSettlement = [json[@"Type"] isEqualToString:@"ForwardCashOut"];
    }
    return self;
}

@end
