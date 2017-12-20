//
//  LWLimitHistoryItemType.m
//  LykkeWallet
//
//  Created by Nikita Medvedev on 15/08/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWLimitHistoryItemType.h"
#import "NSString+Date.h"
#import "LWLimitOrderModel.h"
#import "Macro.h"

@implementation LWLimitHistoryItemType

- (id)initWithJson:(NSDictionary *)json {
	self = [super init];
	if (self) {
		self.identity = json[@"OrderId"];
		self.asset = json[@"Asset"];
		self.assetPair = json[@"AssetPair"];
		self.dateTime = [json[@"DateTime"] toDate];
		self.dateString = json[@"DateTime"];
		self.price = json[@"Price"];
		self.totalCost = json[@"TotalCost"];
		self.status = json[@"Status"];
		self.type = json[@"Type"];
		self.volume = json[@"Volume"];
		self.historyType = LWHistoryItemTypeLimit;
		self.isSettled = YES;
	}
	
	return self;
}

- (BOOL)isBuy {
	return [self.type isEqualToString:kLimitOrderTypeBuy];
}

+ (NSString *)statusTextForStatus:(NSString *)status {
	if (!status.length) {
		return @"";
	}
	
	NSDictionary *messages = @{ kLimitOrderStatusInOrderBook: @"exchange.spot.limitorders.status.inorderbook",
								kLimitOrderStatusProcessing: @"exchange.spot.limitorders.status.processing",
								kLimitOrderStatusMatched: @"exchange.spot.limitorders.status.matched",
								kLimitOrderStatusCancelled: @"exchange.spot.limitorders.status.cancelled" };
	return Localize(messages[status]);
}

@end
