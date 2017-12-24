//
//  LWPacketClientFullNameSet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketClientFullNameSet.h"


@implementation LWPacketClientFullNameSet


#pragma mark - LWPacket

- (NSString *)urlRelative {
    return @"ClientFullName";
}

- (NSDictionary *)params {
    return @{@"FullName" : self.fullName};
}

@end
