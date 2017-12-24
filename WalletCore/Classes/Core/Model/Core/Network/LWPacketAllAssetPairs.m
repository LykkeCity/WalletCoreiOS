//
//  LWPacketAllAssetPairs.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketAllAssetPairs.h"
#import "LWCache.h"
#import "LWAssetPairModel.h"

@implementation LWPacketAllAssetPairs

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
//    NSMutableArray *list = [NSMutableArray new];
    for (NSDictionary *item in result[@"AssetPairs"]) {
//        [list addObject:[[LWAssetPairModel alloc] initWithJSON:item]];
        
        [LWAssetPairModel assetPairWithDict:item];
    }
    
//    [LWCache instance].allAssetPairs=list;
    _assetPairs=[LWCache instance].allAssetPairs;
}

- (NSString *)urlRelative {
    return @"AllAssetPairs";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}



@end
