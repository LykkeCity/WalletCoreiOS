//
//  LWPacketAuthentication.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 13.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketAuthentication.h"
#import "LWPersonalDataModel.h"
#import "LWKeychainManager.h"
#import "LWPrivateKeyManager.h"
//#import "AppDelegate.h"
#import "LWAuthManager.h"
#import "LWCache.h"



@implementation LWPacketAuthentication


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _token = result[@"Token"];
    _status = result[@"KycStatus"];
    _isPinEntered = [result[@"PinIsEntered"] boolValue];
    _personalData = [[LWPersonalDataModel alloc]
                     initWithJSON:[result objectForKey:@"PersonalData"]];
    
    [[LWKeychainManager instance] saveLogin:self.authenticationData.email
                                   password:self.authenticationData.password
                                      token:_token];
    if(result[@"Pin"] != nil)
        [[LWKeychainManager instance] savePIN:result[@"Pin"]];
    
    [[NSUserDefaults standardUserDefaults] setBool:[result[@"CanCashInViaBankCard"] boolValue] forKey:@"CanCashInViaBankCard"];
    [[NSUserDefaults standardUserDefaults] setBool:[result[@"SwiftDepositEnabled"] boolValue] forKey:@"SwiftDepositEnabled"];
    
    [LWCache instance].isUserFromUSA = [result[@"IsUserFromUSA"] boolValue];

//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CanCashInViaBankCard"];//Testing

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [[LWKeychainManager instance] savePersonalData:_personalData];
    if(result[@"NotificationsId"])
    {
        [[LWKeychainManager instance] saveNotificationsTag:result[@"NotificationsId"]];
//        AppDelegate *tmptmp=[UIApplication sharedApplication].delegate;
//        [tmptmp registerForNotificationsInAzureWithTag:result[@"NotificationsId"]];
    }
    if(result[@"EncodedPrivateKey"] && [result[@"EncodedPrivateKey"] length])
    {
        [[LWPrivateKeyManager shared] decryptLykkePrivateKeyAndSave:result[@"EncodedPrivateKey"]];
    }
//    else
//    {
//        [[LWAuthManager instance] requestEncodedPrivateKey];
//    }
    
    if([LWCache instance].passwordIsHashed==NO)
        [[LWAuthManager instance] requestSetPasswordHash:self.authenticationData.password];
    
//        [[LWAuthManager instance] requestSetPasswordHash:[LWPrivateKeyManager hashForString:self.authenticationData.password]];
    
}

- (NSString *)urlRelative {
    return @"Auth";
}

- (NSDictionary *)params {
    return @{@"Email" : self.authenticationData.email,
             @"Password" : [LWCache instance].passwordIsHashed?[LWPrivateKeyManager hashForString:self.authenticationData.password]:self.authenticationData.password,
             @"ClientInfo" : self.authenticationData.clientInfo};
}

@end
