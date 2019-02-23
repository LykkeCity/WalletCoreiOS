//
//  LWPacketAssetsDescriptions.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketAssetsDescriptions.h"
#import "LWAssetDescriptionModel.h"


@implementation LWPacketAssetsDescriptions


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    NSMutableArray *arr = [NSMutableArray new];
    for(NSDictionary *d in result[@"Descriptions"]) {
        [arr addObject:[[LWAssetDescriptionModel alloc] initWithJSON:d]];
    }
    
    _assetsDescriptions = arr;
    
//    _assetDescription = [[LWAssetDescriptionModel alloc] initWithJSON:result];
}

- (NSString *)urlRelative {
    return @"assets/description/list";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params {
    return @{@"Ids": _assetsIds};
}

@end
