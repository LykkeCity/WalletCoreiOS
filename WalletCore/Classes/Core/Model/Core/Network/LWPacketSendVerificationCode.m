//
//  LWPacketSendVerificationCode.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/06/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketSendVerificationCode.h"

@implementation LWPacketSendVerificationCode

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    _accessToken = result[@"AccessToken"];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params {
    return @{
             @"Code":_code,
             @"PartnerId": WalletCoreConfig.partnerId
             };
}

- (NSString *)urlRelative {
    return @"client/codes";
}

@end
