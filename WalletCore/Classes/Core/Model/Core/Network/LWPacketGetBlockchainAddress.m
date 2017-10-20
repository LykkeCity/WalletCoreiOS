//
//  LWPacketGetBlockchainAddress.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 02/03/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketGetBlockchainAddress.h"

@implementation LWPacketGetBlockchainAddress
- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    NSLog(@"%@", response);
    _address = result[@"Address"];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}



- (NSString *)urlRelative {
    
    
    NSString *urlStr = [NSString stringWithFormat:@"Wallets/depositaddress/%@", _assetId];
    
    return urlStr;
}

@end
