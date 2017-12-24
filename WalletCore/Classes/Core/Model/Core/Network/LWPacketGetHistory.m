//
//  LWPacketGetHistory.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGetHistory.h"

@implementation LWPacketGetHistory

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    self.historyArray=(NSArray *)result;
    
    
}

- (NSString *)urlRelative {
    if(self.assetId && [self.assetId isKindOfClass:[NSString class]])
        return [NSString stringWithFormat:@"History?assetId=%@", self.assetId];
    else
        return @"History";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}


@end
