//
//  LWPacketPushSettingsGet.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 08/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketPushSettingsGet.h"
#import "LWCache.h"

@implementation LWPacketPushSettingsGet

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    self.enabled=[result[@"Enabled"] boolValue];
    if(self.enabled)
        [LWCache instance].pushNotificationsStatus=PushNotificationsStatusEnabled;
    else
        [LWCache instance].pushNotificationsStatus=PushNotificationsStatusDisabled;

}

- (NSString *)urlRelative {
    return @"PushSettings";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}


@end
