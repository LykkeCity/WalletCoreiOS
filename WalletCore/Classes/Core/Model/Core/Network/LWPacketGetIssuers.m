//
//  LWPacketGetIssuers.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGetIssuers.h"
#import "LWIssuerModel.h"
#import "LWCache.h"

@implementation LWPacketGetIssuers


- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    NSLog(@"%@", response);
    
    NSMutableDictionary *issuers=[[NSMutableDictionary alloc] init];
    for(NSDictionary *d in result)
    {
        LWIssuerModel *is=[[LWIssuerModel alloc] initWithDict:d];
        issuers[is.identity]=is;
    }
    
    [LWCache instance].issuers=issuers;
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}


- (NSString *)urlRelative {
    return @"Issuers";
}


@end
