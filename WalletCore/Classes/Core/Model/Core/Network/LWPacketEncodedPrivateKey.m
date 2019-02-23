//
//  LWPacketEncodedPrivateKey.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 18/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketEncodedPrivateKey.h"
#import "LWKeychainManager.h"
#import "LWPrivateKeyManager.h"
#import "LWAuthManager.h"

@implementation LWPacketEncodedPrivateKey

-(id) init {
    self = [super init];
    
    _needGeneratePrivateKey = NO;
    
    return self;
}

- (void)parseResponse:(id)response error:(NSError *)error {
    
    
    [super parseResponse:response error:error];
    
    if(self.isRejected && [response[@"Error"][@"Code"] intValue] == 32) {
        _needGeneratePrivateKey = YES;
    }
    
    if (self.isRejected) {
        return;
    }
    
    if(result[@"EncodedPrivateKey"] && [result[@"EncodedPrivateKey"] length])
    {
        [[LWPrivateKeyManager shared] decryptLykkePrivateKeyAndSave:result[@"EncodedPrivateKey"]];
    }
    
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}


- (NSString *)urlRelative {
    return @"Client/keys/encodedmainkey";
}

-(NSDictionary *) params
{
    NSDictionary *params=@{@"AccessToken":_accessToken};
//    NSDictionary *params = @{@"Email":@"a320@a.com"};
    return params;
}


@end
