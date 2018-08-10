//
//  LWPacketChangePINAndPassword.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketChangePINAndPassword.h"
#import "LWRecoveryPasswordModel.h"
#import "LWPrivateKeyManager.h"
#import "LWCache.h"
#import "WalletCoreConfig.h"

@implementation LWPacketChangePINAndPassword

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
}

- (NSString *)urlRelative {
    return @"ChangePinAndPassword";
}

-(NSDictionary *) params
{
    
//    NSString *pass=[LWCache instance].passwordIsHashed?[LWPrivateKeyManager hashForString:self.recModel.password]:self.recModel.password;
    
    NSString *pass = [LWPrivateKeyManager hashForString:self.recModel.password]; //only hash is allowed for new passwords
                                                        
                                                        
    NSDictionary *params=@{
                           @"PartnerId": WalletCoreConfig.partnerId,
                           @"Email":self.recModel.email,
                           @"SignedOwnershipMsg":self.recModel.signature2,
                           @"SmsCode":self.recModel.smsCode,
                           @"NewPin":self.recModel.pin,
                           @"NewPassword": pass,
                           @"NewHint":self.recModel.hint,
                           @"EncodedPrivateKey":[[LWPrivateKeyManager shared] encryptKey:[LWPrivateKeyManager shared].wifPrivateKeyLykke password:self.recModel.password]
                           };
    NSLog(@"%@", params);
    return params;
}


@end
