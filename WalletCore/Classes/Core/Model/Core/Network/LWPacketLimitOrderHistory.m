//
//  LWPacketLimitOrderHistory.m
//  LykkeWallet
//
//  Created by Nikita Medvedev on 04/09/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketLimitOrderHistory.h"
#import "LWTransactionTradeModel.h"
#import "LWHistoryManager.h"

static NSString *kLimitTradeItem = @"LimitTradeEvent";
static NSString *kTradeItem = @"Trade";

@implementation LWPacketLimitOrderHistory

- (void)parseResponse:(id)response error:(NSError *)error {
	[super parseResponse:response error:error];
	
	if (self.isRejected) {
		return;
	}
	self.history = [LWHistoryManager prepareLimitHistory:(NSArray *)result];
}

- (NSString *)urlRelative {
	return [NSString stringWithFormat:@"history/limit/history?orderId=%@", self.orderId];
}

- (GDXRESTPacketType)type {
	return GDXRESTPacketTypeGET;
}

@end
