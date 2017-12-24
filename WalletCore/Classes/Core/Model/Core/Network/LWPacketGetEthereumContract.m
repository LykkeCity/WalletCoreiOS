//
//  LWPacketGetEthereumContract.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 05/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGetEthereumContract.h"

@implementation LWPacketGetEthereumContract

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _contract=result[@"Contract"];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params
{
    return @{@"EthAddress":_address, @"EthPubKey":_pubKey};
}

- (NSString *)urlRelative {
    return @"ethereum/contract";
}


@end
