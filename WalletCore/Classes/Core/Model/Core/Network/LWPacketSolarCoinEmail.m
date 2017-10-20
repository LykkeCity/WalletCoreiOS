//
//  LWPacketSolarCoinEmail.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 06/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketSolarCoinEmail.h"

@implementation LWPacketSolarCoinEmail

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    NSLog(@"%@", response);
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params
{
    
    
    return @{@"Address":_address};
}

- (NSString *)urlRelative {
    return @"email/SolarCoinAddress";
}


@end
