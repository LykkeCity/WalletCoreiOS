//
//  LWPacketMarginDepositWithdraw.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 18/05/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketMarginDepositWithdraw.h"

@implementation LWPacketMarginDepositWithdraw

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    NSLog(@"%@", response);
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params {
    return @{@"AccountId":_accountId, @"Amount":_amount};
}


- (NSString *)urlRelative {
    
    return @"MarginTrading/account/balance";
}


@end
