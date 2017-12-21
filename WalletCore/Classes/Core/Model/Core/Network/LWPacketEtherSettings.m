//
//  LWPacketEtherSettings.m
//  LykkeWallet
//
//  Created by Nikita Medvedev on 15/09/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketEtherSettings.h"
#import "LWCache.h"

@implementation LWPacketEtherSettings

- (void)parseResponse:(id)response error:(NSError *)error {
	[super parseResponse:response error:error];
	
	if (self.isRejected || !response) {
		return;
	}
	
	[LWCache instance].etherAssetId = result[@"EthAssetId"];
    [LWCache instance].ethStepGas = [NSDecimalNumber decimalNumberWithString:result[@"StepGas"]];
    [LWCache instance].ethStepsCount = [result[@"StepsCount"] unsignedIntegerValue];
}

- (NSString *)urlRelative {
	return @"ethereum/settings";
}

- (GDXRESTPacketType)type {
	return GDXRESTPacketTypeGET;
}

@end
