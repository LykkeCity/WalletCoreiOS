//
//  LWPrivateKeyOwnershipMessage.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateKeyOwnershipMessage.h"

@implementation LWPrivateKeyOwnershipMessage

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    self.ownershipMessage=result[@"Message"];
    self.confirmedOwnership=[result[@"Confirmed"] boolValue];
}

- (NSString *)urlRelative {
    if(!self.signature)
        return [NSString stringWithFormat:@"PrivateKeyOwnershipMsg?email=%@", self.email];
    else
        return @"PrivateKeyOwnershipMsg";
}

-(NSDictionary *) params
{
    if(self.signature)
        return @{@"Email":self.email, @"SignedOwnershipMsg":self.signature};
    else
        return nil;
}

- (GDXRESTPacketType)type {
    if(!self.signature)
        return GDXRESTPacketTypeGET;
    else
        return GDXRESTPacketTypePOST;
}


@end
