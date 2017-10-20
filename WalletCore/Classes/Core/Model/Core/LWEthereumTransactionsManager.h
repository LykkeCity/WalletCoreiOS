//
//  LWEthereumTransactionsManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/05/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWNetworkTemplate.h"

@class LWAssetPairModel;
@class LWAssetModel;


@interface LWEthereumTransactionsManager : LWNetworkTemplate

+(LWEthereumTransactionsManager *) shared;

-(void) requestTradeForBaseAsset:(LWAssetModel *)asset pair:(LWAssetPairModel *)pair addressTo:(NSString *) addressTo volume:(NSNumber *)volume completion:(void (^)(NSDictionary *))completion;

-(void) requestCashoutForAsset:(LWAssetModel *)asset volume:(NSNumber *)volume addressTo:(NSString *) addressTo completion:(void (^)(NSDictionary *))completion;

-(void) createEthereumSignManagerForAsset:(LWAssetModel *) asset completion:(void (^)(BOOL))completion;

-(void) logout;

@end
