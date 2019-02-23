//
//  LWPacketSetMarginTermsStatus.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/05/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketSetMarginTermsStatus.h"

@implementation LWPacketSetMarginTermsStatus

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    NSLog(@"%@", response);
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}


- (NSString *)urlRelative {
    
    return @"ClientTrading/termsOfUse/margin/agree";
}


@end
