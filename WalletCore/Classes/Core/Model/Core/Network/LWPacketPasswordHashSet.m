//
//  LWPacketPasswordHashSet.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketPasswordHashSet.h"

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
    return [NSString stringWithFormat:@"HashedPwd"];
}

-(NSDictionary *) params
{
    NSDictionary *params=@{@"PwdHash":_passwordHash};
    return params;
}

@end
