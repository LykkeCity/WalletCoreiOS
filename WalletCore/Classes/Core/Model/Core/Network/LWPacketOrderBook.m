//
//  LWPacketOrderBook.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketOrderBook.h"
#import "LWCache.h"


@implementation LWPacketOrderBook

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }

    
    _sellOrders=[[LWOrderBookElementModel alloc] initWithArray:result[@"BuyOrders"]];  //These orders are from robot. If robot buys then client sells
    
    
    
//    NSMutableArray *aaa = [[NSMutableArray alloc] init];
//    for(NSDictionary *d in result[@"SellOrders"]) {
//        [aaa addObject:d];
//        if(aaa.count > 3) {
//            break;
//        }
//    }
//    
//    _buyOrders = [[LWOrderBookElementModel alloc] initWithArray:aaa];  //Testing!!!!!!!
    
    _buyOrders=[[LWOrderBookElementModel alloc] initWithArray:result[@"SellOrders"]];
    
    

    [LWCache instance].cachedBuyOrders[_assetPairId]=_buyOrders;
    [LWCache instance].cachedSellOrders[_assetPairId]=_sellOrders;
    
    if([_assetPairId isEqualToString:@"BTCLKK"] || [_assetPairId isEqualToString:@"ETHLKK"])
    {
        LWOrderBookElementModel *m=[_sellOrders copy];
        [m invert];
        [LWCache instance].cachedBuyOrders[_assetPairId]=m;
    }
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"OrderBook/%@", _assetPairId];
}


@end
