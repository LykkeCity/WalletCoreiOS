//
//  LWPacketEmailVerificationSet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketEmailVerificationSet.h"
#import "WalletCoreConfig.h"

@implementation LWPacketEmailVerificationSet


#pragma mark - LWPacket

- (NSString *)urlRelative {
    return @"EmailVerification";
}

- (NSDictionary *)params {
    return @{
             @"Email" : self.email,
             @"PartnerId": WalletCoreConfig.partnerId
             };
}

@end
