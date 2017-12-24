//
//  LWPacketGetRefundAddress.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGetRefundAddress.h"
#import "LWCache.h"

@implementation LWPacketGetRefundAddress

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    self.refundAddress=result[@"Address"];
    self.validDays=[result[@"ValidDays"] intValue];
    self.sendAutomatically=[result[@"SendAutomatically"] boolValue];
    
    [LWCache instance].refundAddress=self.refundAddress;
    [LWCache instance].refundDaysValidAfter=self.validDays;
    [LWCache instance].refundSendAutomatically=self.sendAutomatically;
    
}

- (NSString *)urlRelative {
    return @"RefundSettings";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
