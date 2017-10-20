//
//  LWPacketLykkeSettings.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 08/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketLykkeSettings.h"
#import "LWCache.h"

@implementation LWPacketLykkeSettings

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    [LWCache instance].showMyLykkeTab=[result[@"MyLykkeEnabled"] boolValue];
    if([LWCache instance].showMyLykkeTab)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowMyLykkeTabNotification" object:nil];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
    return @"MyLykkeSettings";
}

@end
