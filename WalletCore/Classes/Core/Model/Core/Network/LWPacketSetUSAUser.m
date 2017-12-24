//
//  LWPacketSetUSAUser.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/03/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketSetUSAUser.h"
#import "LWCache.h"

@implementation LWPacketSetUSAUser  //Client/properties/isUserFromUS

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
//    [LWCache instance].isUserFromUSA = true;
    NSLog(@"%@", response);
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params {
    return @{@"IsUserFromUS":@(_isUserFromUSA)};
}

- (NSString *)urlRelative {
    
    
    NSString *urlStr = @"Client/properties/isUserFromUS";
    
    return urlStr;
}

@end
