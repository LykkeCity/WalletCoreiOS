//
//  LWPacketMyLykkeInfo.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketMyLykkeInfo.h"
#import "LWCache.h"

@implementation LWPacketMyLykkeInfo

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _conversionAddress=result[@"BtcConversionWalletAddress"];
    _lkkBalance=result[@"LkkBalance"];
    _lkkTotalAmount=result[@"LkkTotalAmount"];
    _marketValue=result[@"MarketValueUSD"];
    _myEquityPercent=result[@"MyEquityPercent"];
    _numberOfShares=result[@"NumberOfShares"];
    
    [LWCache instance].btcConversionWalletAddress=_conversionAddress;
    
//    _numberOfShares=@(1000000.24);
//    _myEquityPercent=@(33.44);
//    _marketValue=@(1212111);
    
}

- (NSString *)urlRelative {
    return @"MyLykkeInfo";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}


@end
