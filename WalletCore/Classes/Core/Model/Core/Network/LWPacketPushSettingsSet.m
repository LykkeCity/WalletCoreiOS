//
//  LWPacketPushSettingsSet.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 08/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketPushSettingsSet.h"

@implementation LWPacketPushSettingsSet

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    
}


- (NSString *)urlRelative {
    return @"PushSettings";
}

-(NSDictionary *) params
{
    
    NSDictionary *params=@{@"Enabled":@(self.enabled)};
    return params;
}


@end
