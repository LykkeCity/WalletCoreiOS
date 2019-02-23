//
//  LWPacketAssetPair.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 12.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketAssetPair.h"
#import "LWAssetPairModel.h"


@implementation LWPacketAssetPair


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }

    _assetPair = [LWAssetPairModel assetPairWithDict:result[@"AssetPair"]];
//    _assetPair = [[LWAssetPairModel alloc] initWithJSON:result[@"AssetPair"]];
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"AssetPair/%@", self.identity];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
