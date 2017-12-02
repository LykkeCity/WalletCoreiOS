//
//  LWPacketRegistration.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 11.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketRegistration.h"
#import "LWKeychainManager.h"
//#import "AppDelegate.h"
#import "LWPrivateKeyManager.h"
#import "LWCache.h"
#import "WalletCoreConfig.h"


@implementation LWPacketRegistration


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _token = result[@"Token"];
    
    [[LWKeychainManager instance] saveLogin:self.registrationData.email
                                password:self.registrationData.password
                                      token:_token];
    
    if(result[@"NotificationsId"])
    {
        [[LWKeychainManager instance] saveNotificationsTag:result[@"NotificationsId"]];

//        AppDelegate *tmptmp=[UIApplication sharedApplication].delegate;
//        [tmptmp registerForNotificationsInAzureWithTag:result[@"NotificationsId"]];
    }

    
    [[NSUserDefaults standardUserDefaults] setBool:[result[@"CanCashInViaBankCard"] boolValue] forKey:@"CanCashInViaBankCard"];
    [[NSUserDefaults standardUserDefaults] setBool:[result[@"SwiftDepositEnabled"] boolValue] forKey:@"SwiftDepositEnabled"];


}

- (NSString *)urlRelative {
    return @"Registration";
}

- (NSDictionary *)params {
    NSMutableDictionary *params = [@{@"Email" : self.registrationData.email,
                                     @"Password" : [LWPrivateKeyManager hashForString:self.registrationData.password],
                                     @"ClientInfo" : self.registrationData.clientInfo,
                                     @"Hint":self.registrationData.passwordHint} mutableCopy];
    if (self.registrationData.partnerIdentifier != nil) {
        params[@"PartnerId"] = self.registrationData.partnerIdentifier;
    } else {
        params[@"PartnerId"] = WalletCoreConfig.partnerId;
    }
    return [params copy];
}

@end
