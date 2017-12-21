//
//  LWPacketRequestVerificationCode.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/06/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketRequestVerificationCode.h"

@implementation LWPacketRequestVerificationCode

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
    return @"Client/codes";
}

@end
