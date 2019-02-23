//
//  LWLimitOrder.m
//  LykkeWallet
//
//  Created by Nikita Medvedev on 11/08/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWLimitOrderModel.h"
#import "NSString+Date.h"
#import <EasyMapping/EasyMapping.h>
#import "LWAssetPairModel.h"
#import "LWCache.h"
#import "LWAssetModel.h"
#import "LWUtils.h"

@implementation LWLimitOrderModel

// TODO: New implementation, not used now, for comparasion purposes for now only
+ (EKObjectMapping *)objectMapping {
	return [EKObjectMapping mappingForClass:self withBlock:^(EKObjectMapping *mapping) {
		[mapping mapPropertiesFromDictionary:@{ @"Id": @"identity",
												@"OrderType": @"type" }];
		[mapping mapKeyPath:@"DateTime" toProperty:@"date" withValueBlock:^(NSString *key, NSString *value) {
			return [value toDate];
		}];
		[mapping mapPropertiesFromArrayToPascalCase:@[@"volume",
													  @"remainingVolume",
													  @"assetPair",
													  @"price"]];
	}];
}

- (instancetype)initWithJSON:(id)json {
	self = [super initWithJSON:json];
	if (self) {
		self.identity = json[@"Id"];
		self.date = [json[@"DateTime"] toDate];
		self.type = json[@"OrderType"];
		self.volume = json[@"Volume"];
		self.remainingVolume = json[@"RemainingVolume"];
		self.remainingOtherVolume = json[@"RemainingOtherVolume"];
		self.assetPair = json[@"AssetPair"];
		self.price = json[@"Price"];
		self.totalCost = json[@"TotalCost"];
	}
	return self;
}

- (NSString *)asset {
	LWAssetPairModel *pair = [LWCache assetPairById:self.assetPair];
	return pair.normalBaseAsset;
}

- (NSString *)quotingAsset {
	LWAssetPairModel *pair = [LWCache assetPairById:self.assetPair];
	return pair.normalQuotingAsset;
}

- (NSString *)assetDisplayingId {
	return [LWCache assetById:[self asset]].displayId;
}

- (NSString *)quotingAssetDisplayingId {
	return [LWCache assetById:[self quotingAsset]].displayId;
}

- (BOOL)isSell {
	return [self.type isEqualToString:kLimitOrderTypeSell];
}

- (BOOL)isBuy {
	return [self.type isEqualToString:kLimitOrderTypeBuy];
}

- (NSString *)formattedPrice {
	LWAssetPairModel *pair = [LWCache assetPairById:self.assetPair];
	return [LWUtils formatVolumeNumber:self.price currencySign:self.quotingAssetDisplayingId accuracy:pair.accuracy.intValue removeExtraZeroes:YES];
}

- (NSString *)formattedVolume {
	LWAssetModel *normalAsset = [LWCache assetById:self.asset];
	return [LWUtils formatVolumeNumber:self.volume currencySign:self.assetDisplayingId accuracy:normalAsset.accuracy.intValue removeExtraZeroes:YES];
}

- (NSString *)formattedTotalCost {
	LWAssetModel *quotingAsset = [LWCache assetById:self.quotingAsset];
	return [LWUtils formatVolumeNumber:self.totalCost currencySign:self.quotingAssetDisplayingId accuracy:quotingAsset.accuracy.intValue removeExtraZeroes:YES];
}

- (NSString *)formattedRemainingVolume {
	LWAssetModel *normalAsset = [LWCache assetById:self.asset];
	return [LWUtils formatVolumeNumber:self.remainingVolume currencySign:self.assetDisplayingId accuracy:normalAsset.accuracy.intValue removeExtraZeroes:YES];
}

- (NSString *)formattedRemainingOtherVolume {
	LWAssetModel *quotingAsset = [LWCache assetById:self.quotingAsset];
	return [LWUtils formatVolumeNumber:self.remainingOtherVolume currencySign:self.quotingAssetDisplayingId accuracy:quotingAsset.accuracy.intValue removeExtraZeroes:YES];
}

@end
