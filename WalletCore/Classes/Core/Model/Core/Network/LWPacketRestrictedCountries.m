//
//  LWPacketRestrictedCountries.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 14.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketRestrictedCountries.h"


@implementation LWPacketRestrictedCountries


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _countries = result[@"RestrictedCountries"];
}

- (NSString *)urlRelative {
    return @"RestrictedCountries";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
