//
//  LWPrivateKeyOwnershipMessage.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateKeyOwnershipMessage.h"
#import "WalletCoreConfig.h"

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
    return @"PrivateKeyOwnershipMsg";
}

-(NSDictionary *) params
{
    if(self.signature)
        return @{@"PartnerId": WalletCoreConfig.partnerId, @"Email":self.email, @"SignedOwnershipMsg":self.signature };
    else
        return @{@"PartnerId": WalletCoreConfig.partnerId, @"Email":self.email };
}

- (GDXRESTPacketType)type {
    if(!self.signature)
        return GDXRESTPacketTypeGET;
    else
        return GDXRESTPacketTypePOST;
}


@end
