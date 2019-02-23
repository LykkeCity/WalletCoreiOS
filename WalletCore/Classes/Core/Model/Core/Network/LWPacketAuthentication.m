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
#import "LWAuthManager.h"
#import "LWCache.h"
#import "LWUserDefault.h"
#import "WalletCoreConfig.h"

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
  if(result[@"Pin"]) {
    [[LWKeychainManager instance] savePIN:result[@"Pin"]];
  }
  
  [LWKeychainManager instance].canCashInViaBankCard = [result[@"CanCashInViaBankCard"] boolValue];
  [LWKeychainManager instance].swiftDepositEnabled = [result[@"SwiftDepositEnabled"] boolValue];
  
  [LWKeychainManager instance].userFromUSA = [result[@"IsUserFromUSA"] boolValue];
  
  [[LWKeychainManager instance] savePersonalData:_personalData];
  if(result[@"NotificationsId"]) {
    [[LWKeychainManager instance] saveNotificationsTag:result[@"NotificationsId"]];
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate registerForNotificationsInAzureWithTag:result[@"NotificationsId"]];
  }
}

- (NSString *)urlRelative {
  return @"Auth";
}

- (NSDictionary *)params {
  NSDictionary *params = @{ @"Email" : self.authenticationData.email,
                            @"Password" : [LWCache instance].passwordIsHashed
                            ? [LWPrivateKeyManager hashForString:self.authenticationData.password]
                            : self.authenticationData.password,
                            @"ClientInfo" : self.authenticationData.clientInfo,
                            @"PartnerId": WalletCoreConfig.partnerId
                            };
  return params;
}

@end
