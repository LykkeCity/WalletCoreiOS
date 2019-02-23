//
//  LWPacketKYCStatusGet.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 13.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketKYCStatusGet.h"


@implementation LWPacketKYCStatusGet


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _status = result[@"KycStatus"];
}

- (NSString *)urlRelative {
    return @"KycStatus";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
