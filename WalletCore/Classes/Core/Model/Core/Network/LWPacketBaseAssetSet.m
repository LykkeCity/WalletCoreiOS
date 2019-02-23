//
//  LWPacketBaseAssetSet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketBaseAssetSet.h"


@implementation LWPacketBaseAssetSet


#pragma mark - LWPacket

- (NSString *)urlRelative {
    return @"BaseAsset";
}

- (NSDictionary *)params {
    return @{@"Id" : self.identity};
}

@end
