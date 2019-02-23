//
//  LWPacketPhoneVerificationSet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketPhoneVerificationSet.h"


@implementation LWPacketPhoneVerificationSet


#pragma mark - LWPacket

- (NSString *)urlRelative {
    return @"CheckMobilePhone";
}

- (NSDictionary *)params {
    return @{@"PhoneNumber" : self.phone};
}

@end
