//
//  LWMarginalWalletsDataManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWNetworkTemplate.h"

@class LWMarginalPosition;
@class LWMarginalAccount;
@class LWHistoryArray;

static NSString *kChartDataFetchedNotification = @"ChartDataFetched";

@interface LWMarginalWalletsDataManager : LWNetworkTemplate

+ (instancetype)shared;

@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) NSMutableArray *accounts;
@property (strong, nonatomic) NSMutableArray *positions;
@property (readonly) BOOL hasLiveAccount;

@property (readonly, nonatomic) NSArray *allAssets;

@property BOOL positionsLoaded;

@property BOOL flagListeningForAssets;

+(void) start;

+(void) stop;

//-(void) startListeningForOrderBook:(void (^)(NSArray *))manager assetId:(NSString *) assetId;

-(void) startListeningForOrderBook:(NSString *) assetId;

- (void)loadChartDataAndStartListeningForAssetsFromCurrentList;
- (void)loadChartDataAndStartListeningForAssets:(NSArray *)assetIds;
- (void)stopListeningForAsset:(NSString *)assetId;

-(void) createPosition:(LWMarginalPosition *) position withCompletion:(void(^)(NSString *)) completion;
-(void) closePosition:(LWMarginalPosition *) position;
-(void) changePositionLimits:(LWMarginalPosition *) position withCompletion:(void(^)(NSString *)) completion;
//-(void) changeCurrentAccountTo:(LWMarginalAccount *) account;
-(void) depositToAccount:(LWMarginalAccount *) account amount:(double) amount completion:(void(^)(BOOL)) completion;
-(void) withdrawFromAccount:(LWMarginalAccount *) account amount:(double) amount completion:(void(^)(BOOL)) completion;


-(void) loadHistoryForAccount:(LWMarginalAccount *) account withCompletion:(void(^)(LWHistoryArray *, NSError *)) completion;

-(LWMarginalAccount *) currentAccount;

//-(void) reloadAssetPairs; //Testing

-(void) reloadAccounts;

@end
