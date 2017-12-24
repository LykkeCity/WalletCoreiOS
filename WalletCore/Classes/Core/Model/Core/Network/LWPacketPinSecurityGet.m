//
//  LWPacketPinSecurityGet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 13.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketPinSecurityGet.h"


@implementation LWPacketPinSecurityGet


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _isPassed = [result[@"Passed"] boolValue];
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"PinSecurity?pin=%@", self.pin];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
