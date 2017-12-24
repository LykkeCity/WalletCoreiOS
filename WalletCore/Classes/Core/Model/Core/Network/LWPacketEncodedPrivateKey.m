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

- (void)parseResponse:(id)response error:(NSError *)error {
    
//    if([response[@"Error"] isKindOfClass:[NSDictionary class]] && [response[@"Error"][@"Code"] intValue]==1)  //Error occures
//    {
////        [[LWPrivateKeyManager shared] generatePrivateKey];
////        [[LWAuthManager instance] requestSaveClientKeysWithPubKey:[LWPrivateKeyManager shared].publicKeyLykke encodedPrivateKey:[LWPrivateKeyManager shared].encryptedKeyLykke];
//        return;
//    }
    
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    if(result[@"EncodedPrivateKey"] && [result[@"EncodedPrivateKey"] length])
    {
        [[LWPrivateKeyManager shared] decryptLykkePrivateKeyAndSave:result[@"EncodedPrivateKey"]];
    }
    
    
}


- (NSString *)urlRelative {
    return @"EncodedPrivateKey";
}

-(NSDictionary *) params
{
    NSDictionary *params=@{@"Password":[LWKeychainManager instance].password};
    return params;
}


@end
