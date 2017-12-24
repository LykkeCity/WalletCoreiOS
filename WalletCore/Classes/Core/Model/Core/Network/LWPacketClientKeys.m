//
//  LWClientKeys.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 18/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketClientKeys.h"
#import "LWPrivateKeyManager.h"

@implementation LWPacketClientKeys

- (void)parseResponse:(id)response error:(NSError *)error {
    
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    else
    {
        [[LWPrivateKeyManager shared] decryptLykkePrivateKeyAndSave:_encodedPrivateKey];
    }
    
}


- (NSString *)urlRelative {
    return @"ClientKeys";
}

-(NSDictionary *) params
{
//    NSDictionary *params=@{@"PubKey":_pubKey, @"EncodedPrivateKey":_encodedPrivateKey, @"PrivateKey":[LWPrivateKeyManager shared].wifPrivateKeyLykke};
    NSDictionary *params=@{@"PubKey":_pubKey, @"EncodedPrivateKey":_encodedPrivateKey, @"TempKey":[LWPrivateKeyManager shared].wifPrivateKeyLykke};
    return params;
}


@end
