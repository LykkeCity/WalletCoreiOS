//
//  LWLimitOrderDetailsPacket.m
//  LykkeWallet
//
//  Created by Nikita Medvedev on 21/08/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketLimitOrderDetails.h"

@implementation LWPacketLimitOrderDetails

- (void)parseResponse:(id)response error:(NSError *)error {
	[super parseResponse:response error:error];
	
	if (self.isRejected) {
		return;
	}
	
	self.marketOrder = [[LWExchangeInfoModel alloc] initWithJSON:result];
}

- (NSDictionary *)params {
	return @{ @"orderId": self.orderId };
}

- (NSString *)urlRelative {
	return @"history/limit/order";
}

- (GDXRESTPacketType)type {
	return GDXRESTPacketTypeGET;
}

@end
