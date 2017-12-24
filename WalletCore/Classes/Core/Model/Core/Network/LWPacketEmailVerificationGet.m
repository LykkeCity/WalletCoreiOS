//
//  LWPacketEmailVerificationGet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketEmailVerificationGet.h"
#import "WalletCoreConfig.h"

@implementation LWPacketEmailVerificationGet


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];

    if (self.isRejected) {
        return;
    }
    
    _isPassed = [result[@"Passed"] boolValue];

}

- (NSString *)urlRelative {
    return @"EmailVerification";
}

- (NSDictionary *)params {
    return @{
             @"email": self.email,
             @"code": self.code,
             @"partnerId": WalletCoreConfig.partnerId
             };
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
