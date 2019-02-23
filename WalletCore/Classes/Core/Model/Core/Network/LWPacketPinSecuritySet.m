//
//  LWPacketPinSecuritySet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 13.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketPinSecuritySet.h"
#import "LWKeychainManager.h"


@implementation LWPacketPinSecuritySet


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    [[LWKeychainManager instance] savePIN:self.pin];
}


- (NSString *)urlRelative {
//    return @"PinSecurity";
    return @"PinSecurity";
}

- (NSDictionary *)params {
//    return @{@"Pin" : self.pin};
    NSDictionary *params=@{@"Pin":self.pin};
    
    return params;
}

@end

