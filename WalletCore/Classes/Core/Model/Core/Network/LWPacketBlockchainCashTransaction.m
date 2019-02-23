//
//  LWPacketBlockchainCashTransaction.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 16.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketBlockchainCashTransaction.h"
#import "LWAssetBlockchainModel.h"


@implementation LWPacketBlockchainCashTransaction


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
    return [NSString stringWithFormat:@"BcnTransactionByCashOperation?id=%@", self.cashOperationId];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
