//
//  LWPacketLimitOrderTrades.m
//  LykkeWallet
//
//  Created by Nikita Medvedev on 23/08/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketLimitOrderTrades.h"
#import "LWTransactionTradeModel.h"
#import <BlocksKit/BlocksKit.h>
#import <WalletCore/WalletCore-Swift.h>

static NSString *kTradeItem = @"Trade";

@implementation LWPacketLimitOrderTrades

- (void)parseResponse:(id)response error:(NSError *)error {
	[super parseResponse:response error:error];
	
	if (self.isRejected) {
		return;
	}
	self.history = [(NSArray *)result bk_map:^id(NSDictionary *obj) {
		LWTransactionTradeModel *model = [[LWTransactionTradeModel alloc] initWithJSON:obj[kTradeItem]];
		return [LWTradeHistoryItemType convertFromNetworkModel:model];
	}];
}

- (NSString *)urlRelative {
	return [NSString stringWithFormat:@"History/limit/trades?orderId=%@", self.orderId];
}

- (GDXRESTPacketType)type {
	return GDXRESTPacketTypeGET;
}

@end
