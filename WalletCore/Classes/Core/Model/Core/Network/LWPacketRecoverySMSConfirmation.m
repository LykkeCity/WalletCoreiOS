//
//  LWPacketRecoverySMSConfirmation.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketRecoverySMSConfirmation.h"
#import "LWRecoveryPasswordModel.h"

@implementation LWPacketRecoverySMSConfirmation

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    self.recModel.securityMessage2=result[@"NewOwnershipMsgToSign"];
    self.recModel.phoneNumber=result[@"PhoneNumber"];
}

- (NSString *)urlRelative {
    return @"RecoverySmsConfirmation";
}

-(NSDictionary *) params
{
    return @{@"Email":self.recModel.email, @"SignedOwnershipMsg":self.recModel.signature1};
}


@end
