//
//  LWPacketBlockchainTransaction.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketBlockchainTransaction.h"
#import "LWAssetBlockchainModel.h"


@implementation LWPacketBlockchainTransaction


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }

    _blockchain = nil;
    
    id object = [result objectForKey:@"Transaction"];
    if (object && ![object isKindOfClass:[NSNull class]]) {
        _blockchain = [[LWAssetBlockchainModel alloc] initWithJSON:object];
    }
}

- (NSString *)urlRelative {
    NSString *tempUrl = [NSString stringWithFormat:@"BcnTransaction?id=%@", self.orderId];
 
//    NSString *tempUrl = [NSString stringWithFormat:@"BlockchainTransaction?blockChainHash=%@", self.orderId];
    return tempUrl;
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
