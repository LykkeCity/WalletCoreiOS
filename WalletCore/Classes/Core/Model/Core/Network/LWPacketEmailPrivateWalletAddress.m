//
//  LWPacketEmailPrivateWalletAddress.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketEmailPrivateWalletAddress.h"

@implementation LWPacketEmailPrivateWalletAddress

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    NSLog(@"%@", response);
    
    
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params
{
    return @{@"Address":_address, @"WalletName":_name};
}

- (NSString *)urlRelative {
    return @"email/PrivateWalletAddress";
}


@end
