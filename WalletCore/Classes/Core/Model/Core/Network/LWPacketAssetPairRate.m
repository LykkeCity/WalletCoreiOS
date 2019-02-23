//
//  LWPacketAssetPairRate.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketAssetPairRate.h"
#import "LWAssetPairRateModel.h"


@implementation LWPacketAssetPairRate


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }

    NSLog(@"GOT ASSET PAIR RATE %@", response);
    _assetPairRate = [[LWAssetPairRateModel alloc] initWithJSON:result[@"Rate"]];
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"AssetPairRates/%@", self.identity];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
