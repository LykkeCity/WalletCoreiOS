//
//  LWPacketCheckDocumentsToUpload.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 12.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketCheckDocumentsToUpload.h"


@implementation LWPacketCheckDocumentsToUpload


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _documentsStatus = [[LWDocumentsStatus alloc] initWithJSON:result];
}

- (NSString *)urlRelative {
    return @"CheckDocumentsToUpload";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
