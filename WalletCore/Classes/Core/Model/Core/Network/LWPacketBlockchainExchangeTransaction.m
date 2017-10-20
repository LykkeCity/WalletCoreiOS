//
//  LWPacketBlockchainExchangeTransaction.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 16.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketBlockchainExchangeTransaction.h"
#import "LWAssetBlockchainModel.h"


@implementation LWPacketBlockchainExchangeTransaction


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
    return [NSString stringWithFormat:@"BcnTransactionByExchange?id=%@", self.exchangeOperationId];
//    self.exchangeOperationId=@"2d35d7dd-9dad-4dc4-8f5f-6198b8338b10";
//    return [NSString stringWithFormat:@"BcnTransaction?id=%@", self.exchangeOperationId]; //Testing
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
