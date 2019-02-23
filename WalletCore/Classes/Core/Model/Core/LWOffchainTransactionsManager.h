//
//  LWOffchainTransactionsManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWNetworkTemplate.h"

@class LWPrivateWalletModel;
@class LWAssetModel;
@class LWMarginalAccount;
@class LWSwiftCashOutDetailsModel;

@interface LWOffchainTransactionsManager : LWNetworkTemplate

+(LWOffchainTransactionsManager *) shared;

- (void)sendSwapRequestForAsset:(NSString *)baseAsset pair:(NSString *)assetPairId volume:(NSNumber *)volume completion:(void (^)(NSDictionary *))completion;

- (void) requestCashOutSwiftWithParams:(NSDictionary *)params completion:(void (^)(NSDictionary *))completion;
- (void) requestCashOut:(NSDecimalNumber *)amount assetId:(NSString *)assetId multiSig:(NSString *)multiSig completion:(void (^)(NSDictionary *))completion;
-(void) requestTransferToMarginAccount:(LWMarginalAccount *)account amount:(NSNumber *) amount completion:(void (^)(NSDictionary *))completion;
- (void)getSwiftCashOutDetails:(void (^)(LWSwiftCashOutDetailsModel *, NSError *))completion;

- (void)requestTrustedOperationWithId:(NSString *)operationId completion:(void(^)(BOOL success))completion;
- (void)requestCancelTrustedOperationWithCompletion:(void(^)(BOOL success))completion;
	
-(void) getRequests;

@end
