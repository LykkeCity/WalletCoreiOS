//
//  LWKeychainManager.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 19.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"

@class LWPersonalDataModel;

@interface LWKeychainManager : NSObject {
    
}

SINGLETON_DECLARE

@property (readonly, nonatomic) NSString *login;
@property (readonly, nonatomic) NSString *token;
@property (readonly, nonatomic) NSString *address;
@property (readonly, nonatomic) NSString *password;
@property (readonly, nonatomic) NSString *notificationsTag;
@property (readonly, nonatomic) NSString *encodedPrivateKeyLykke;

@property (readonly, nonatomic) BOOL     isAuthenticated;


#pragma mark - Common

- (void)saveLogin:(NSString *)login password:(NSString *) password token:(NSString *)token;
- (void)savePersonalData:(LWPersonalDataModel *)personalData;
- (void)saveAddress:(NSString *)address;

-(void) saveNotificationsTag:(NSString *) tag;

-(void) saveEncodedLykkePrivateKey:(NSString *) privateKey;

-(void) saveNotEncodedPrivateKey:(NSString *) privateKey;
//-(void) savePrivateKey:(NSString *) privateKey forWalletAddress:(NSString *) address;

//-(NSString *) privateKeyForWalletAddress:(NSString *) address;

-(NSString *) encodedPrivateKeyForEmail:(NSString *) email;

-(LWPersonalDataModel *) personalData;

- (void)clear;

-(void) saveFullName:(NSString *) fullName;

-(void) savePIN:(NSString *) pin;

-(void) saveOffchainLastPrivateKey:(NSString *) key forAssetId: (NSString *) assetId;
-(NSString *) offchainLastPrivateKeyForAsset:(NSString *) assetId;

#pragma mark - Properties

- (NSString *)fullName;
-(NSString *) pin;

@end
