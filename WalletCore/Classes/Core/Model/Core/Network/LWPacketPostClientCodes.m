//
//  LWPacketPostClientCodes.m
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/22/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

#import "LWPacketPostClientCodes.h"

@implementation LWPacketPostClientCodes

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _accessToken = result[@"AccessToken"];
}

- (NSString *)urlRelative {
    return @"Client/codes";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params
{
    NSDictionary *params=@{@"Code": [NSString stringWithFormat:@"%@", self.codeSms]};
    return params;
}

@end
