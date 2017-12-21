//
//  LWPacketPasswordHashSet.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketPasswordHashSet.h"
#import "LWPrivateKeyManager.h"

@implementation LWPacketPasswordHashSet

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

- (NSString *)urlRelative {
    return @"HashedPwd";
}

- (NSDictionary *)params {
    NSDictionary *params = @{ @"PwdHash": [LWPrivateKeyManager hashForString:self.password] };
    return params;
}

@end
