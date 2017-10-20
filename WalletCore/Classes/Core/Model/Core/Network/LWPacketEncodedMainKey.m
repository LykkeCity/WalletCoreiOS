//
//  LWPacketEncodedMainKey.m
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/22/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

#import "LWPacketEncodedMainKey.h"

@implementation LWPacketEncodedMainKey

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _encodedPrivateKey = result[@"EncodedPrivateKey"];
    
    if(result[@"EncodedPrivateKey"] && [result[@"EncodedPrivateKey"] length])
    {
        [[LWPrivateKeyManager shared] decryptLykkePrivateKeyAndSave:result[@"EncodedPrivateKey"]];
    }
}

- (NSString *)urlRelative {
    return @"Client/keys/encodedmainkey";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params
{
    NSDictionary *params=@{@"AccessToken": [NSString stringWithFormat:@"%@", self.accessToken]};
    return params;
}
@end
