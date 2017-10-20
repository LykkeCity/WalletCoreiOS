//
//  LWPacketVoiceCall.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 21/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketVoiceCall.h"

@implementation LWPacketVoiceCall


- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

- (NSString *)urlRelative {
    return @"RequestVoiceCall";
}

-(NSDictionary *) params
{
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    params[@"Email"]=_email;
    if(self.phone)
        params[@"PhoneNumber"]=_phone;
    return params;
}

@end
