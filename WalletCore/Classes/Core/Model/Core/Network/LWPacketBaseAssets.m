//
//  LWPacketBaseAssets.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketBaseAssets.h"
#import "LWAssetModel.h"
#import "LWCache.h"


@implementation LWPacketBaseAssets


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected || !response) {
        return;
    }
    
    NSMutableArray *list = [NSMutableArray new];
    for (NSDictionary *item in result[@"Assets"]) {
        for(LWAssetModel *asset in [LWCache instance].allAssets) {
            if([asset.identity isEqualToString:item[@"Id"]]) {
                [list addObject:asset];
                break;
            }
        }
    }
    _assets = list;

    [LWCache instance].baseAssets = _assets;
}

- (NSString *)urlRelative {
    return @"BaseAssets";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
