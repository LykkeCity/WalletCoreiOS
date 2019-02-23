//
//  LWPacketClientState.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/06/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketClientState.h"
#import "LWCache.h"
#import "LWMarginalWalletsDataManager.h"
#import "LWKeychainManager.h"
#import "LWUserDefault.h"
#import "WalletCoreConfig.h"

@implementation LWPacketClientState


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    [self saveValues];
}

- (NSString *)urlRelative {
    return @"ClientState";
}

- (NSDictionary *)params {
    if([LWKeychainManager instance].login) {
    return @{@"email" : [LWKeychainManager instance].login, @"partnerId": WalletCoreConfig.partnerId};
    }
    else {
        return [super params];
    }
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

-(void) saveValues {
  
  BOOL prevShowMarginWallets = [LWKeychainManager instance].showMarginWallets;
  BOOL prevLiveMarginWallets = [LWKeychainManager instance].showMarginWalletsLive;
  
  [LWCache instance].passwordIsHashed = [result[@"IsPwdHashed"] boolValue];
	[LWCache instance].icoIsEnabled = [result[@"ICO"][@"IsEnabled"] boolValue];
	[LWCache instance].icoShowBanner = [result[@"ICO"][@"ShowBanner"] boolValue];
  [LWKeychainManager instance].showMarginWallets = [result[@"MarginTrading"] boolValue];
  [LWKeychainManager instance].showMarginWalletsLive = [result[@"MarginTradingLive"] boolValue];
  [LWKeychainManager instance].useOffchainRequests = [result[@"IsOffchain"] boolValue];
  [LWUserDefault instance].marginTermsOfUseAgreed = [result[@"MarginTermsOfUseAgreed"] boolValue];
  
  if([LWKeychainManager instance].showMarginWallets && prevShowMarginWallets == false && [LWKeychainManager instance].isAuthenticated) {
    [LWMarginalWalletsDataManager start];
  }
  
  if([LWKeychainManager instance].showMarginWalletsLive && prevLiveMarginWallets == false && [LWKeychainManager instance].isAuthenticated) {
    if([LWMarginalWalletsDataManager shared].positionsLoaded) {
      [[LWMarginalWalletsDataManager shared] reloadAccounts];
    }
  }
  
}

@end
