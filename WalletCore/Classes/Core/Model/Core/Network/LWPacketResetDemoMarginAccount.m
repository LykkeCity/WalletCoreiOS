//
//  LWPacketResetDemoMarginAccount.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 18/05/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketResetDemoMarginAccount.h"

@implementation LWPacketResetDemoMarginAccount

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    NSLog(@"%@", response);
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeDELETE;
}


- (NSString *)urlRelative {
    
    return [NSString stringWithFormat:@"MarginTrading/account/reset/%@",_accountId];
}

@end
