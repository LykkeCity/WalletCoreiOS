//
//  LWPrivateWalletsManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
#import "LWNetworkTemplate.h"

@class LWPrivateWalletModel;
@class LWPKBackupModel;
@class LWPKTransferModel;

@interface LWPrivateWalletsManager : LWNetworkTemplate

@property (strong, nonatomic) NSArray *wallets;

-(void) loadWalletsWithCompletion:(void(^)(NSArray *)) completion;
-(void) loadWalletBalances:(NSString *) address withCompletion:(void (^)(NSArray *))completion;

-(void) loadHistoryForWallet:(NSString *) address assetId:(NSString *) assetId withCompletion:(void(^)(NSArray *)) completion;

-(void) addNewWallet:(LWPrivateWalletModel *) wallet   withCompletion:(void (^)(BOOL))completion;
-(void) updateWallet:(LWPrivateWalletModel *) wallet withCompletion:(void (^)(BOOL))completion;
-(void) defrostColdStorageWallet:(LWPrivateWalletModel *) wallet withCompletion:(void (^)(BOOL))completion;

-(void) deleteWallet:(NSString *) address withCompletion:(void (^)(BOOL))completion;

-(void) backupPrivateKeyWithModel:(LWPKBackupModel *) model  withCompletion:(void (^)(BOOL))completion;

-(void) requestTransferTransaction:(LWPKTransferModel *) transfer withCompletion:(void(^)(NSDictionary *)) completion;
-(void) broadcastTransaction:(NSString *) raw identity:(NSString *) identity withCompletion:(void(^)(BOOL)) completion;

+ (instancetype) shared;

@end
