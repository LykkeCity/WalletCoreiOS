//
//  LWLimitHistoryItemType.h
//  LykkeWallet
//
//  Created by Nikita Medvedev on 15/08/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWBaseHistoryItemType.h"

static NSString *kLimitOrderStatusInOrderBook = @"InOrderBook";
static NSString *kLimitOrderStatusProcessing = @"Processing";
static NSString *kLimitOrderStatusMatched = @"Matched";
static NSString *kLimitOrderStatusCancelled = @"Cancelled";

@interface LWLimitHistoryItemType : LWBaseHistoryItemType

@property (copy, nonatomic) NSString *status;
@property (copy, nonatomic) NSString *assetPair;
@property (copy, nonatomic) NSNumber *price;
@property (copy, nonatomic) NSNumber *totalCost;
@property (copy, nonatomic) NSString *dateString;
@property (copy, nonatomic) NSString *type;

- (id)initWithJson:(NSDictionary *)json;

- (BOOL)isBuy;

+ (NSString *)statusTextForStatus:(NSString *)status;

@end
