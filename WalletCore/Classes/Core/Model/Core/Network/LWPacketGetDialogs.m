//
//  LWPacketGetDialogs.m
//  LykkeWallet
//
//  Created by Nikita Medvedev on 06/09/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketGetDialogs.h"
#import <BlocksKit/BlocksKit.h>
#import <WalletCore/WalletCore-Swift.h>

@implementation LWPacketGetDialogs

- (void)parseResponse:(id)response error:(NSError *)error {
	[super parseResponse:response error:error];
	
	if (self.isRejected) {
		return;
	}
	
	NSArray *jsonArray = result[@"Dialogs"];
	self.dialogs = [jsonArray bk_map:^id(NSDictionary *json) {
		return [[LWDialogsModel alloc] initWithJSON:json];
	}];
}

- (GDXRESTPacketType)type {
	return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
	return @"client/dialogs";
}

@end
