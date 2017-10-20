//
//  LWPacketRegistrationGet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 21.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketRegistrationGet.h"


@implementation LWPacketRegistrationGet


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _status = result[@"KycStatus"];
    _isPinEntered = [result[@"PinIsEntered"] boolValue];
}

- (NSString *)urlRelative {
    return @"Registration";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
