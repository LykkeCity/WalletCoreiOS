//
//  LWPacketRequestVerificationCode.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/06/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketRequestVerificationCode.h"
#import "WalletCoreConfig.h"

@implementation LWPacketRequestVerificationCode

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
    return @"Client/codes";
}

- (NSDictionary *)params {
    return @{
             @"PartnerId": WalletCoreConfig.partnerId
             };
}

@end
