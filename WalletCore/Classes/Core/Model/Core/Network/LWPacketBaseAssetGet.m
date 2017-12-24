//
//  LWPacketBaseAssetGet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketBaseAssetGet.h"


@implementation LWPacketBaseAssetGet


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _asset = [[LWAssetModel alloc] initWithJSON:result[@"Asset"]];
}

- (NSString *)urlRelative {
    return @"BaseAsset";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
