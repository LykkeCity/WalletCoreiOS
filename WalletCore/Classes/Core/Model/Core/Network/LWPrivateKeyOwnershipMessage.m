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
    if(self.signature)
        return @"PrivateKeyOwnershipMsg";
    else
        return @"PrivateKeyOwnershipMsg/privateKeyOwnerShipMsg";
}

-(NSDictionary *) params
{
    if(self.signature)
        return @{@"Email":self.email, @"SignedOwnershipMsg":self.signature, @"PartnerId": WalletCoreConfig.partnerId};
    else
        return @{@"email":self.email, @"partnerId": WalletCoreConfig.partnerId};
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}


@end
