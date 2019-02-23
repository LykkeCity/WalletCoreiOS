//
//  LWPacketGetMainScreenInfo.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketGetMainScreenInfo.h"
#import "LWCache.h"

@implementation LWPacketGetMainScreenInfo

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if(result) {
        _success = true;
    }
    _tradingBalance = [result[@"TradingWallet"] doubleValue];
    _privateBalance = [result[@"PrivateWallets"] doubleValue];
    _marginBalance = [result[@"MarginWallets"] doubleValue];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}


- (NSString *)urlRelative {
    
    _success = NO;
    NSString *assetIDParam = self.assetId;
    if (assetIDParam == nil)  assetIDParam = [LWCache instance].baseAssetId;
    
    
    NSString *urlStr = [NSString stringWithFormat:@"Client/balances/%@", assetIDParam];
    
    return urlStr;
}

@end
