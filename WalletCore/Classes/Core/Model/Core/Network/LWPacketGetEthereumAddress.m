//
//  LWPacketGetEthereumAddress.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGetEthereumAddress.h"

@implementation LWPacketGetEthereumAddress

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }

    self.ethereumAddress=result[@"Address"];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
    return @"EthereumExchangeAddress";
}


@end
