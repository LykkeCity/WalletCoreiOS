//
//  LWPacketTransfer.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketTransfer.h"


@implementation LWPacketTransfer

#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
}

- (NSString *)urlRelative {
    return @"Transfer";
}

- (NSDictionary *)params {
    return @{@"AssetId"   : self.assetId,
             @"Recipient" : self.recepientId,
             @"Amount"    : self.amount};
}


@end
