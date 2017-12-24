//
//  LWPacketLogout.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 21/02/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketLogout.h"

@implementation LWPacketLogout

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    NSLog(@"%@", response);
    

}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}


- (NSString *)urlRelative {
    NSLog(@"Logout api called");
    
    return @"Auth/LogOut";
}

@end
