//
//  LWPacketEmailVerificationSet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketEmailVerificationSet.h"


@implementation LWPacketEmailVerificationSet


#pragma mark - LWPacket

- (NSString *)urlRelative {
    return @"EmailVerification";
}

- (NSDictionary *)params {
    return @{@"email" : self.email};
}

@end
