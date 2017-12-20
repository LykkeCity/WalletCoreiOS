//
//  LWPacketSendDialog.m
//  LykkeWallet
//
//  Created by Nikita Medvedev on 06/09/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketSendDialog.h"

@implementation LWPacketSendDialog

- (void)parseResponse:(id)response error:(NSError *)error {
	[super parseResponse:response error:error];
	
	if (self.isRejected) {
		return;
	}
}

- (GDXRESTPacketType)type {
	return GDXRESTPacketTypePOST;
}

- (NSString *)urlRelative {
	return @"client/dialogs";
}

- (NSDictionary *)params {
	return @{ @"Id": self.dialogId,
			  @"ButtonId": self.buttonId };
}

@end
