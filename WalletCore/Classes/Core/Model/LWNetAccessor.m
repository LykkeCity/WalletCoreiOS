    //
//  LWNetAccessor.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 13.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWNetAccessor.h"


@implementation LWNetAccessor


#pragma mark - Common

- (void)sendPacket:(LWPacket *)packet {

    packet.caller=self.caller;
    self.caller=nil;

    [self sendPacket:packet info:nil];
}

- (void)sendPacket:(LWPacket *)packet info:(NSDictionary *)userInfo {
    NSDictionary *dict=[[GDXNet instance] send:packet userInfo:userInfo method:GDXNetSendMethodREST];
    
    NSLog(@"Send packet returned dict: %@", dict);
}

@end
