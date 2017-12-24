//
//  LWPacketAppSettings.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketAppSettings.h"
#import "LWAppSettingsModel.h"
#import "LWAssetModel.h"
#import "LWCache.h"


@implementation LWPacketAppSettings


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected || !response) {
        return;
    }
    
    _appSettings = [[LWAppSettingsModel alloc] initWithJSON:result];
    
    // refresh cache
    [LWCache instance].refreshTimer = self.appSettings.rateRefreshPeriod;
    [LWCache instance].baseAssetId = self.appSettings.baseAsset.identity;
}

- (NSString *)urlRelative {
    return @"AppSettings";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
