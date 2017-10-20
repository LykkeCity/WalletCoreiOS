//
//  LWPacketMarketOrder.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 11.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketMarketOrder.h"
#import "LWAssetDealModel.h"


@implementation LWPacketMarketOrder


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _model = [[LWAssetDealModel alloc] initWithJSON:result[@"MarketOrder"]];
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"MarketOrder?orderId=%@", self.orderId];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
