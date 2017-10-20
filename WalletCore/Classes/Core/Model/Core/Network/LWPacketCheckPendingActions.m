//
//  LWPacketCheckPendingActions.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketCheckPendingActions.h"
#import "LWAuthManager.h"
#import "LWKeychainManager.h"
#import "LWPacketAccountExist.h"


@implementation LWPacketCheckPendingActions

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    _hasUnsignedTransactions = [result[@"UnsignedTxs"] intValue] > 0;
    
    _hasOffchainRequests = [result[@"OffchainRequests"] intValue] > 0;
    _needReinit = [result[@"NeedReinit"] boolValue];

}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}



- (NSString *)urlRelative {
    
    
    NSString *urlStr = @"client/pendingActions";
    
    return urlStr;
}


@end
