//
//  LWPacketExchangeInfoGet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 16.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketExchangeInfoGet.h"
#import "LWExchangeInfoModel.h"


@implementation LWPacketExchangeInfoGet


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _model = [[LWExchangeInfoModel alloc] initWithJSON:result];
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"ExchangeInfo?exchangeId=%@", self.exchangeId];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
