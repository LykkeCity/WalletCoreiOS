//
//  LWPacketEmailVerificationGet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketEmailVerificationGet.h"


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
    
    NSString *sss=[NSString stringWithFormat:@"EmailVerification?email=%@&code=%@", self.email, self.code];
    NSLog(@"%@", sss);
    return [NSString stringWithFormat:@"EmailVerification?email=%@&code=%@", self.email, self.code];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
