//
//  LWPacketMarginChartData.m
//  LykkeWallet
//
//  Created by Nikita Medvedev on 24/07/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketMarginChartData.h"
#import "LWCache.h"

@implementation LWPacketMarginChartData

- (void)parseResponse:(id)response error:(NSError *)error {
	[super parseResponse:response error:error];
	
	_chartData = result[@"ChartData"];
}

- (GDXRESTPacketType)type {
	return self.assetIds ? GDXRESTPacketTypePOST : GDXRESTPacketTypeGET;
}

- (NSString *)urlBase {
	return [LWCache instance].marginalApiUrl;
}

- (NSString *)urlRelative {
	return self.assetIds ? @"init/chart/filtered" : @"init/chart";
}

- (NSDictionary *)params {
	if (self.assetIds) {
		return @{ @"AssetIds": self.assetIds };
	}
	else {
		return [super params];
	}
}

@end
