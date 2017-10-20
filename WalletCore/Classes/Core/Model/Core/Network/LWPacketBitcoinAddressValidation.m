//
//  LWPacketBitcoinAddressValidation.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 02/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketBitcoinAddressValidation.h"

@implementation LWPacketBitcoinAddressValidation


- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    
    if (self.isRejected) {
        return;
    }
    
    self.isValid=[result[@"Valid"] boolValue];

    
}


- (NSString *)urlRelative {
    return @"PubkeyAddressValidation";
}

-(NSDictionary *) params
{
    return @{@"pubkeyAddress":self.bitcoinAddress};
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}



@end
