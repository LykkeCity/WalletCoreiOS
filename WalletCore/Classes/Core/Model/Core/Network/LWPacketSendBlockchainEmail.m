//
//  LWPacketSendBlockchainEmail.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 16.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketSendBlockchainEmail.h"


@implementation LWPacketSendBlockchainEmail


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
}

- (NSString *)urlRelative {
    
    return @"EmailMeWalletAddress";
}

-(NSDictionary *) params
{
    NSMutableDictionary *dict=[@{@"AssetId":self.assetId} mutableCopy];
    if(self.address)
        dict[@"BcnAddress"]=self.address;
    
    return dict;
}

@end
