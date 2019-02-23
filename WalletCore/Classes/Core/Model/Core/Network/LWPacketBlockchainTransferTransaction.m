//
//  LWPacketBlockchainTransferTransaction.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 19.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketBlockchainTransferTransaction.h"
#import "LWAssetBlockchainModel.h"


@implementation LWPacketBlockchainTransferTransaction


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
    return [NSString stringWithFormat:@"BcnTransactionByTransfer?id=%@", self.transferOperationId];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
