//
//  LWPacketSettingSignOrder.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketSettingSignOrder.h"
#import "LWCache.h"


@implementation LWPacketSettingSignOrder


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _signOrderBeforeGo = [result[@"SignOrderBeforeGo"] boolValue];

    [LWCache instance].shouldSignOrder = _signOrderBeforeGo;
}

- (NSString *)urlRelative {
    return @"SettingSignOrder";
}

- (NSDictionary *)params {
    return @{@"SignOrderBeforeGo" : [NSNumber numberWithBool:self.shouldSignOrder]};
}

@end
