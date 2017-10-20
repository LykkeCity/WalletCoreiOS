//
//  LWTransactionTransferModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 12.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTransactionTransferModel.h"
#import "NSString+Date.h"


@implementation LWTransactionTransferModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _identity = [json objectForKey:@"Id"];
        _volume   = [json objectForKey:@"Volume"];
        NSString *date = [json objectForKey:@"DateTime"];
        _dateTime = [date toDate];
        _asset    = [json objectForKey:@"Asset"];
        _assetId    = [json objectForKey:@"AssetId"];
        _iconId   = [json objectForKey:@"IconId"];
        _blockchainHash = [json objectForKey:@"BlockChainHash"];
        _addressFrom=json[@"AddressFrom"];
        _addressTo=json[@"AddressTo"];
        _isSettled=[json[@"IsSettled"] boolValue];
        
    }
    return self;
}

@end
