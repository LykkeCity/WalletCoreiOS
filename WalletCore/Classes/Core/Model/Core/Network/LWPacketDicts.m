//
//  LWPacketDicts.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 23.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketDicts.h"
#import "LWAssetsDictionaryItem.h"
#import "LWCache.h"


@implementation LWPacketDicts


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected || !response) {
        return;
    }

    // read assets
    NSMutableArray *assets = [NSMutableArray new];
    for (NSDictionary *item in result[@"Assets"]) {
        [assets addObject:[[LWAssetsDictionaryItem alloc] initWithJSON:item]];
    }
    _assetsDictionary = assets;
    
    [LWCache instance].assetsDict = [assets copy];
}

- (NSString *)urlRelative {
    return @"Dicts";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
