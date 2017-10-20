//
//  LWPacketMarket.m
//  LykkeWallet
//
//  Created by Georgi Stanev on 8/3/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketMarket.h"
#import "LWMarketModel.h"
#import "LWKeychainManager.h"
#import "LWCache.h"

@implementation LWPacketMarket
    
#pragma mark - LWPacket
    
- (void)parseResponse:(id)response error:(NSError *)error {
    
    
    NSMutableArray *list = [NSMutableArray new];
    for (NSDictionary *item in response) {
        [list addObject:[[LWMarketModel alloc] initWithJSON:item]];
    }
    
    _marketAssetPairs = list;
}
    
- (NSString *)urlRelative {
    return @"Market";
}

- (NSString *)urlBase {
    return [NSString stringWithFormat:@"https://%@/api/", @"public-api.lykke.com"];
}
    
- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}
@end
