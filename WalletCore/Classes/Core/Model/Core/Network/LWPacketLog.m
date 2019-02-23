//
//  LWPacketLog.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 28.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketLog.h"


@implementation LWPacketLog {
    
}


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
}

- (NSDictionary *)params {
    return @{@"Data" : self.log};
}

- (NSString *)urlRelative {
    return @"ClientLog";
}

@end
