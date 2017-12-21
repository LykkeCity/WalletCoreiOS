//
//  LWKeychainManager.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 19.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKeychainManager.h"
#import "LWPersonalDataModel.h"
#import "LWConstants.h"
#import "LWPrivateKeyManager.h"
#import <Valet/Valet.h>
#import <EasyMapping/EasyMapping.h>
#import <WalletCore/WalletCore-Swift.h>

static NSString * const kKeychainManagerAppId    = @"LykkeWallet";
static NSString * const kKeychainManagerToken    = @"Token";
static NSString * const kKeychainManagerLogin    = @"Login";
static NSString * const kKeychainManagerPhone    = @"Phone";
static NSString * const kKeychainManagerFullName = @"FullName";
static NSString * const kKeychainManagerAddress  = @"Address";
static NSString * const kKeychainManagerPassword  = @"Password";
static NSString * const kKeychainManagerPIN  = @"Pin";

static NSString * const kKeychainManagerNotificationsTag  = @"NotificationsTag";

static NSString * const kKeychainManagerUserPrivateWalletsAddresses=@"UserWalletsAddresses";

static NSString * const kKeychainManagerPersonalData = @"PersonalData";

static NSString * const kIsUserFromUSAKey = @"TheUserIsFromUSA";
static NSString * const kShowMarginWalletsKey = @"ShowMarginWallets";
static NSString * const kShowMarginWalletsLiveKey = @"ShowMarginWalletsLive";
static NSString * const kUseOffchainOperationsKey = @"UseOffchainOperations";
static NSString * const kSwiftDepositEnabledKey = @"SwiftDepositEnabled";
static NSString * const kCanCashInViaBankCardKey = @"CanCashInViaBankCard";
static NSString * const kMainScreenValuesKey = @"CurrentMainScreenValues";

@interface LWKeychainManager () {
    VALValet *valet;
}

@end


@implementation LWKeychainManager


#pragma mark - Root

SINGLETON_INIT {
    self = [super init];
    if (self) {
//        valet = [[VALValet alloc] initWithIdentifier:kKeychainManagerAppId
//                                       accessibility:VALAccessibilityWhenUnlocked];
        valet = [[VALValet alloc] initWithIdentifier:kKeychainManagerAppId
                                       accessibility:VALAccessibilityAlways];
//        [self clear]; //Andrey
    }
    return self;
}

- (void)setBool:(BOOL)boolValue forKey:(NSString *)key {
  [valet setString:[NSString stringWithFormat:@"%@", boolValue ? @"YES" : @"NO"] forKey:key];
}

- (BOOL)boolForKey:(NSString *)key {
  return [[valet stringForKey:key] boolValue];
}

#pragma mark - Common


- (void)saveLogin:(NSString *)login password:(NSString *)password token:(NSString *)token
{
    [valet setString:token forKey:kKeychainManagerToken];
    [valet setString:login forKey:kKeychainManagerLogin];
    [valet setString:password forKey:kKeychainManagerPassword];
}

- (void)savePersonalData:(LWPersonalDataModel *)personalData {
    if (personalData) {
        if (personalData.phone
            && ![personalData.phone isKindOfClass:[NSNull class]] && personalData.phone.length) {
            [valet setString:personalData.phone    forKey:kKeychainManagerPhone];
        }
        if (personalData.fullName
            && ![personalData.fullName isKindOfClass:[NSNull class]]) {
            [valet setString:personalData.fullName forKey:kKeychainManagerFullName];
        }
        
        if(personalData.jsonString)
            [valet setString:personalData.jsonString forKey:kKeychainManagerPersonalData];
    }
}

-(void) saveFullName:(NSString *)fullName
{
    [valet setString:fullName forKey:kKeychainManagerFullName];

}

-(LWPersonalDataModel *) personalData
{
    NSString *json=[valet stringForKey:kKeychainManagerPersonalData];
    if(!json)
        return nil;
    
    
    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    LWPersonalDataModel *model=[[LWPersonalDataModel alloc] initWithJSON:dict];
    return model;
}

- (void)saveAddress:(NSString *)address {
    [valet setString:address forKey:kKeychainManagerAddress];
}

-(void) saveNotificationsTag:(NSString *)tag
{
    [valet setString:tag forKey:kKeychainManagerNotificationsTag];
}


- (void)clear {
  [valet removeObjectForKey:kKeychainManagerToken];
  [valet removeObjectForKey:kKeychainManagerLogin];
  [valet removeObjectForKey:kKeychainManagerPhone];
  [valet removeObjectForKey:kKeychainManagerFullName];
  [valet removeObjectForKey:kKeychainManagerPassword];
  [valet removeObjectForKey:kKeychainManagerNotificationsTag];
  [valet removeObjectForKey:kKeychainManagerPersonalData];
  [valet removeObjectForKey:kKeychainManagerPIN];
  [valet removeObjectForKey:kMainScreenValuesKey];
}

-(void) clearWholeKeychain {
    [valet removeAllObjects];
}

-(void) saveEncodedLykkePrivateKey:(NSString *)privateKey
{
    if(![self login])
        return;
    [valet setString:privateKey forKey:[self login]];
}

-(void) saveNotEncodedPrivateKey:(NSString *)privateKey {
    if(![self login])
        return;
    [valet setString:privateKey forKey:[NSString stringWithFormat:@"KEYFOR%@", [self login]]];

}

-(NSString *) encodedPrivateKeyForEmail:(NSString *)email
{
    return [valet stringForKey:email];
}

-(void) saveOffchainLastPrivateKey:(NSString *)key forAssetId:(NSString *)assetId {
    if(self.isAuthenticated == NO) {
        return;
    }
    [valet setString:key forKey:[NSString stringWithFormat:@"OffchainKeyForUser%@Asset%@", [self login], assetId]];
}

-(NSString *) offchainLastPrivateKeyForAsset:(NSString *)assetId {
    if(self.isAuthenticated == NO) {
        return @"";
    }
    NSString *key = [valet stringForKey:[NSString stringWithFormat:@"OffchainKeyForUser%@Asset%@", [self login], assetId]];
    if(!key) {
        key = @"";
    }
    
    return key;
}

//-(void) savePrivateKey:(NSString *)privateKey forWalletAddress:(NSString *)address
//{
//    NSData *data=[valet objectForKey:kKeychainManagerUserPrivateWalletsAddresses];
//    NSMutableArray *wallets;// = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
//    if(data)
//        wallets=[[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
//    else
//        wallets=[[NSMutableArray alloc] init];
//    if([wallets containsObject:address]==NO)
//    {
//        [wallets addObject:address];
//        data = [NSKeyedArchiver archivedDataWithRootObject:wallets];
//        [valet setObject:data forKey:kKeychainManagerUserPrivateWalletsAddresses];
//    }
//    [valet setString:privateKey forKey:address];
//}

-(void) savePIN:(NSString *) pin
{
    [valet setString:pin forKey:kKeychainManagerPIN];
}

-(NSString *) pin
{
    return [valet stringForKey:kKeychainManagerPIN];
}


#pragma mark - Properties

- (NSString *)login {
    return [valet stringForKey:kKeychainManagerLogin];
}

- (NSString *)token {
    return [valet stringForKey:kKeychainManagerToken];
}

-(NSString *) password
{
    return [valet stringForKey:kKeychainManagerPassword];
}

-(NSString *) notificationsTag
{
    return [valet stringForKey:kKeychainManagerNotificationsTag];
}

-(NSString *) encodedPrivateKeyLykke
{
    
    return [valet stringForKey:[self login]];
}

//-(NSString *) privateKeyForWalletAddress:(NSString *) address
//{
//    return [valet stringForKey:address];
//}


- (NSString *)blueAddress {
    
#ifdef TEST
    return WalletCoreConfig.blueTestingServer;
#else
    return kBlueProductionServer;
#endif
    
}


- (NSString *)address {
    
//    return kTestingTestServer; //Pothberry

//    return kProductionServer;//Testing
    
//    return @"http://testtestest.me";//Andrey
    
//    return kStagingTestServer;

#ifdef PROJECT_IATA
    return kDevelopTestServer;
#else
    
#ifdef TEST
    NSString *result = [valet stringForKey:kKeychainManagerAddress];
    // validate for nil, empty or non-existing addresses
    if (!result || [result isEqualToString:@""] ||
        (![result isEqualToString:kTestingTestServer] &&
         ![result isEqualToString:kDevelopTestServer] &&
         ![result isEqualToString:kStagingTestServer])) {
        NSString *testingServer = WalletCoreConfig.testingServer;
        [self saveAddress:testingServer];
        return testingServer;
    }
    return result;
#else
    return kProductionServer;
#endif
    
#endif
}

- (BOOL)isAuthenticated {
    return (self.token && ![self.token isEqualToString:@""] && [LWPrivateKeyManager shared].privateKeyLykke);
}

- (NSString *)fullName {
    return [valet stringForKey:kKeychainManagerFullName];
}

- (void)setUserFromUSA:(BOOL)userFromUSA {
  [self setBool:userFromUSA forKey:kIsUserFromUSAKey];
}

- (BOOL)isUserFromUSA {
  return [self boolForKey:kIsUserFromUSAKey];
}

- (void)setShowMarginWallets:(BOOL)showMarginWallets {
  [self setBool:showMarginWallets forKey:kShowMarginWalletsKey];
}

- (BOOL)showMarginWallets {
  return [self boolForKey:kShowMarginWalletsKey];
}

- (void)setShowMarginWalletsLive:(BOOL)showMarginWalletsLive {
  [self setBool:showMarginWalletsLive forKey:kShowMarginWalletsLiveKey];
}

- (BOOL)showMarginWalletsLive {
  return [self boolForKey:kShowMarginWalletsLiveKey];
}

- (void)setSwiftDepositEnabled:(BOOL)swiftDepositEnabled {
  [self setBool:swiftDepositEnabled forKey:kSwiftDepositEnabledKey];
}

- (BOOL)isSwiftDepositEnabled {
  return [self boolForKey:kSwiftDepositEnabledKey];
}

- (void)setUseOffchainRequests:(BOOL)useOffchainRequests {
  [self setBool:useOffchainRequests forKey:kUseOffchainOperationsKey];
}

- (BOOL)useOffchainRequests {
  return [self boolForKey:kUseOffchainOperationsKey];
}

- (void)setCanCashInViaBankCard:(BOOL)canCashInViaBankCard {
  [self setBool:canCashInViaBankCard forKey:kCanCashInViaBankCardKey];
}

- (BOOL)canCashInViaBankCard {
  return [self boolForKey:kCanCashInViaBankCardKey];
}

- (LWMainScreenData *)mainScreenData {
  NSString *json = [valet stringForKey:kMainScreenValuesKey];
  NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
  if (jsonData == nil) {
    return nil;
  }
  NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
  return [EKMapper objectFromExternalRepresentation:dictionary withMapping:[LWMainScreenData objectMapping]];
}

- (void)setMainScreenData:(LWMainScreenData *)mainScreenData {
  NSDictionary *dictionary = mainScreenData ? [EKSerializer serializeObject:mainScreenData withMapping:[LWMainScreenData objectMapping]] : nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
  NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  [valet setString:json forKey:kMainScreenValuesKey];
}

@end
