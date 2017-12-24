//
//  LWPacketAssetPairRates.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketAssetPairRates.h"
#import "LWAssetPairRateModel.h"


@implementation LWPacketAssetPairRates


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    NSMutableArray *list = [NSMutableArray new];
    for (NSDictionary *item in result[@"Rates"]) {
        [list addObject:[[LWAssetPairRateModel alloc] initWithJSON:item]];
    }
    _assetPairRates = list;
}

- (NSString *)urlRelative {
    if(_ignoreBaseAsset) {
        return @"AssetPairRates?ignoreBase=true";

    }
    else {
        return @"AssetPairRates";
    }
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
