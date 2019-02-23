//
//  LWPacketPersonalData.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 26.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketPersonalData.h"
#import "LWPersonalDataModel.h"


@implementation LWPacketPersonalData


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _data = [[LWPersonalDataModel alloc] initWithJSON:result];
}

- (NSString *)urlRelative {
    return @"PersonalData";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
