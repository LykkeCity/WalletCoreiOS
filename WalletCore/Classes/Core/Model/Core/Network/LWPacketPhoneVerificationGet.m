//
//  LWPacketPhoneVerificationGet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketPhoneVerificationGet.h"


@implementation LWPacketPhoneVerificationGet


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _isPassed = [result[@"Passed"] boolValue];
    
}

- (NSString *)urlRelative {
    NSString *url = [NSString stringWithFormat:@"CheckMobilePhone?phoneNumber=%@&code=%@",  [self.phone stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],self.code];
    return url;
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
