//
//  LWPacketGetClientCodes.m
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/21/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

#import "LWPacketGetClientCodes.h"

@implementation LWPacketGetClientCodes

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    //Hardcoded for development
    _codeSms = @"0000";
}

- (NSString *)urlRelative {
    return @"Client/codes";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
