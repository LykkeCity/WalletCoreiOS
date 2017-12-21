
//
//  LWMarginalWalletsDataManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMarginalWalletsDataManager.h"
#import <MDWamp/MDWamp.h>
#import "LWMarginalWalletAsset.h"
#import "NSString+Date.h"
#import "LWKeychainManager.h"
#import "LWMarginalAccount.h"
#import "LWMarginalPosition.h"
#import "LWMWHistoryElement.h"
#import "LWHistoryArray.h"
#import "LWPacketMarginChartData.h"
#import "AFNetworking.h"
#import "LWAuthManager.h"
#import "LWCache.h"
#import "LWWatchList.h"
#import "LWWatchListElement.h"
#import "LWUtils.h"

@import UIKit;

static NSInteger kMinAssetsForPricesUpdateMethod = 40;
static double kMinNotificationUpdateInterval = 0.1;
static double kRequestTimeout = 30.0;

@interface LWMarginalWalletsDataManager() <MDWampClientDelegate, MDWampTransportDelegate, LWAuthManagerDelegate>
{
  MDWamp *wamp;
  BOOL flagConnected;
  
  
  NSMutableArray *listeningOrderbooks;
  NSMutableArray *listeningAssets;
  
  double lastNotificationSentTime;
  double lastChartDataNotificationSentTime;
  
  NSMutableArray *assetsTemplates;
}

@end

@implementation LWMarginalWalletsDataManager

- (instancetype)init {
  self = [super init];
  
  lastNotificationSentTime = 0;
  _flagListeningForAssets = NO;
  _positionsLoaded = false;
  
  listeningOrderbooks = [[NSMutableArray alloc] init];
  listeningAssets = [[NSMutableArray alloc] init];
  _positions = [[NSMutableArray alloc] init];
  
  return self;
}

+ (instancetype)shared {
  if([LWKeychainManager instance].showMarginWallets == false) {
    return nil;
  }
  static LWMarginalWalletsDataManager *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[LWMarginalWalletsDataManager alloc] init];
    
  });
  return shared;
}

- (BOOL)hasLiveAccount {
	for(LWMarginalAccount *acc in self.accounts) {
		if(acc.isDemo == false) {
			return true;
		}
	}

	return false;
}

- (NSString *)baseURLPath {
  return [LWCache instance].marginalApiUrl;
}

- (NSMutableURLRequest *)createRequestWithAPI:(NSString *)apiMethod
                            httpMethod:(NSString *)httpMethod
                         getParameters:(NSDictionary *)getParams
                        postParameters:(NSDictionary *)postParams {
  NSMutableURLRequest *requst = [super createRequestWithAPI:apiMethod httpMethod:httpMethod getParameters:getParams postParameters:postParams];
  requst.timeoutInterval = kRequestTimeout;
  return requst;
}

- (void)start {
  if([AFNetworkReachabilityManager sharedManager].isReachable && [LWCache instance].wampServerUrl) {
    wamp.delegate=nil;
    [wamp disconnect];
    
    flagConnected=NO;
    
    [listeningAssets removeAllObjects];
    _flagListeningForAssets=NO;
    
    NSURL *url = [NSURL URLWithString:[LWCache instance].wampServerUrl];
    
    MDWampTransportWebSocket *websocket = [[MDWampTransportWebSocket alloc] initWithServer:url protocolVersions:@[kMDWampProtocolWamp2msgpack, kMDWampProtocolWamp2json]];
    
    wamp = [[MDWamp alloc] initWithTransport:websocket realm:@"mtcrossbar" delegate:self];
    
    [wamp connect];
  } else {
    if([LWKeychainManager instance].token) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self start];
      });
    }
  }
}

+(void) start
{
  LWMarginalWalletsDataManager *manager=[LWMarginalWalletsDataManager shared];
  [manager start];
}

+(void) stop {
  [[LWMarginalWalletsDataManager shared] stop];
}

-(void) stop {
  [wamp disconnect];
  
  _positionsLoaded = false;
  _positions = [[NSMutableArray alloc] init];
  _accounts = [[NSMutableArray alloc] init];
}

// Called when client has connected to the server
- (void) mdwamp:(MDWamp*)wamp sessionEstablished:(NSDictionary*)info
{
  flagConnected=YES;
  
  [self loadInitialData];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"WampConnected" object:nil];
}

// Called when client disconnect from the server
- (void) mdwamp:(MDWamp *)wamp closedSession:(NSInteger)code reason:(NSString*)reason details:(NSDictionary *)details
{
  flagConnected=NO;
  _flagListeningForAssets=NO;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"WampDisconnected" object:nil];
  if([LWKeychainManager instance].token) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self start];
    });
  }
}

-(void) testForExeption {
  [wamp call:@"init.exception" payload:@{} complete:^(MDWampResult *result, NSError *error){
    
    
  }];
}

- (void)startListeningForOrderBook:(NSString *)assetId {
  if (!flagConnected) {
    [wamp connect];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self startListeningForOrderBook:assetId];
    });
    return;
  }
  if (flagConnected == NO) {
    return;
  }
  
  if ([listeningOrderbooks containsObject:assetId]) {
    return;
  }
  [listeningOrderbooks addObject:assetId];
  NSString *channel=[@"orderbook.update." stringByAppendingString:assetId];
  [wamp subscribe:channel onEvent:^(MDWampEvent *payload) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
    });
  } result:^(NSError *error) {
    if (error) {
      [self logErrorWithMessage:@"marginal.prices.error"];
      [listeningOrderbooks removeObject:assetId];
    } else {
      [wamp call:@"orderbook.init" payload:assetId complete:^(MDWampResult *result, NSError *error){
        
      }];
    }
  }];
}

- (BOOL)shouldUsePricesUpdateMethod {
  return [self assets].count > kMinAssetsForPricesUpdateMethod;
}

- (void)startListeningForAssets {
  if ([self shouldUsePricesUpdateMethod]) {
    [self startListeningForAllAssets];
  }
  else {
    for (LWMarginalPosition *position in _positions) {
      [self startListeningForAsset:position.assetPairId];
    }
  }
}

- (void)startListeningForAsset:(NSString *)assetId {
  if ([listeningAssets containsObject:assetId] || [self shouldUsePricesUpdateMethod]) {
    return;
  }
  [listeningAssets addObject:assetId];
  
  NSString *method = [NSString stringWithFormat:@"prices.update.%@", assetId];
  [self startListeningForAssetsWithMethod:method];
}

- (void)startListeningForAllAssets {
  [self startListeningForAssetsWithMethod:@"prices.update"];
}

- (void)startListeningForAssetsWithMethod:(NSString *)method {
  [wamp subscribe:method onEvent:^(MDWampEvent *payload) {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
      NSString *changedAssetId = nil;
      BOOL flagWasChange = false;
      
      if (payload.arguments.count == 1) {
        if (!_assets) {
          return;
        }
        NSDictionary *dict=payload.arguments[0];
        
        LWMarginalWalletRate *rate=[LWMarginalWalletRate new];
        rate.ask=[dict[@"Ask"] doubleValue];
        rate.bid=[dict[@"Bid"] doubleValue];
        
        NSDate *date=[dict[@"Date"] toDateWithMilliSeconds];
        rate.timestamp=[date timeIntervalSinceReferenceDate];
        NSArray *assetsSnapshot = [NSArray arrayWithArray:_assets];
        for (LWMarginalWalletAsset *asset in assetsSnapshot) {
          if ([asset.identity isEqualToString:dict[@"Instrument"]]) {
            flagWasChange = [asset ratesChanged:@[rate]];
            if (flagWasChange) {
              changedAssetId = asset.identity;
            }
          }
        }
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        if (changedAssetId) {
          [self sendRefreshNotification];
          [[NSNotificationCenter defaultCenter] postNotificationName:[@"PricesChanged" stringByAppendingString:changedAssetId]  object:nil];
        }
      });
    });
  } result:^(NSError *error) {
    if (error) {
      [self logErrorWithMessage:@"marginal.error.prices"];
      _flagListeningForAssets = NO;
    } else {
      _flagListeningForAssets = YES;
    }
  }];
}

- (void)stopListeningForAsset:(NSString *)assetId {
  if (![listeningAssets containsObject:assetId] || [self shouldUsePricesUpdateMethod]) {
    return;
  }
  
  for (LWMarginalPosition *position in _positions) {
    if ([position.assetPairId isEqualToString:assetId]) {
      return;
    }
  }
  
  NSString *method = [NSString stringWithFormat:@"prices.update.%@", assetId];
  [wamp unsubscribe:method result:^(NSError *error) {
    if (error) {
      [self logErrorWithMessage:@"marginal.error.connection"];
    }
    else {
      [listeningAssets removeObject:assetId];
    }
  }];
}

-(void) loadInitialData
{
  if(flagConnected==NO)
  {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self loadInitialData];
    });
  }//wamp.subscription.list
  
  NSURLRequest *request = [self createRequestWithAPI:@"init/data"
                            httpMethod:@"GET"
                         getParameters:nil
                        postParameters:nil];
  
  [self sendRequest:request completion:^(NSDictionary *response) {
    if ([response isKindOfClass:[NSDictionary class]]) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if([LWKeychainManager instance].isAuthenticated == false) {
          return;
        }
        
        if(!_assets)
        {
          _assets=[[NSMutableArray alloc] init];
        }
        
        id demoInfo = response[@"Demo"];
        if ([demoInfo isKindOfClass:[NSDictionary class]]) {
          [self fillAccounts:demoInfo[@"Accounts"] isDemo:YES];
        }
        
        id liveInfo = response[@"Live"];
        if ([liveInfo isKindOfClass:[NSDictionary class]]) {
          [self fillAccounts:liveInfo[@"Accounts"] isDemo:NO];
        }
        
        if(_accounts.count == 0) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [self logErrorWithMessage:@"marginal.error.noaccounts"];
          });
          return;
        }
        else {
          BOOL found = NO;
          for(LWMarginalAccount *acc in _accounts) {
            if(acc.isCurrent) {
              found = YES;
              break;
            }
          }
          if(found == NO) {
            [_accounts[0] setIsCurrent:YES];
          }
        }
        
        [self createAssets:response[@"Assets"]];
        
        if ([demoInfo isKindOfClass:[NSDictionary class]]) {
          [self fillTradingConditions:demoInfo[@"TradingConditions"] isDemo:YES];
        }
        
        if ([liveInfo isKindOfClass:[NSDictionary class]]) {
          [self fillTradingConditions:liveInfo[@"TradingConditions"] isDemo:NO];
        }
        
        
        if(_assets.count == 0) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [self logErrorWithMessage:@"marginal.error.assets"];
          });
          return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
          [self getPositions];
          [self subscribeForUsersTopic];
        });
      });
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self logErrorWithMessage:@"marginal.error.data"];
      });
    }
  }];
  
}

- (void)loadChartDataAndStartListeningForAssetsFromCurrentList {
  NSMutableArray *assetIds = @[].mutableCopy;
  LWWatchList *currentList = [LWCache instance].currentMarginWatchList;
  if (currentList) {
    for (LWWatchListElement *element in currentList.elements) {
      [assetIds addObject:element.assetId];
    }
  }
  else {
    for (LWMarginalWalletAsset *asset in [self assets]) {
      [assetIds addObject:asset.identity];
    }
  }
  
  [self loadChartDataAndStartListeningForAssets:assetIds];
}

- (void)loadAllChartData {
  [LWAuthManager instance].caller = self;
  [[LWAuthManager instance] requestAllMarginChartData];
}

- (void)loadChartDataAndStartListeningForAssets:(NSArray *)assetIds {
  assetIds = [[NSOrderedSet orderedSetWithArray:assetIds] array];
  
  [LWAuthManager instance].caller = self;
  [[LWAuthManager instance] requestMarginChartDataForAssets:assetIds];
}

-(void) getPositions
{
  NSURLRequest *request = [self createRequestWithAPI:@"orders" httpMethod:@"GET" getParameters:nil postParameters:nil];
  
  [self sendRequest:request completion:^(NSDictionary *response) {
    if ([response isKindOfClass:[NSDictionary class]]) {
      NSMutableArray *demoPositions = [NSMutableArray new];
      if ([response[@"Demo"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *demoPositionsInfo = response[@"Demo"];
        if ([demoPositionsInfo[@"Positions"] count] > 0) {
          [demoPositions addObjectsFromArray:demoPositionsInfo[@"Positions"]];
        }
        if ([demoPositionsInfo[@"Orders"] count] > 0) {
          [demoPositions addObjectsFromArray:demoPositionsInfo[@"Orders"]];
        }
      }
      
      NSMutableArray *livePositions = [NSMutableArray new];
      if ([response[@"Live"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *livePositionsInfo = response[@"Live"];
        if ([livePositionsInfo[@"Positions"] count] > 0) {
          [demoPositions addObjectsFromArray:livePositionsInfo[@"Positions"]];
        }
        if ([livePositionsInfo[@"Orders"] count] > 0) {
          [demoPositions addObjectsFromArray:livePositionsInfo[@"Orders"]];
        }
      }
      
      NSMutableArray *arr = [[NSMutableArray alloc] init];
      [arr addObjectsFromArray:demoPositions];
      [arr addObjectsFromArray:livePositions];
      
      for(NSDictionary *d in arr)
      {
        [self updateOrAddPositionWithDict:d];
      }
      
      for(int i=0;i<_positions.count;i++)
      {
        LWMarginalPosition *pos=_positions[i];
        BOOL found=NO;
        for(NSDictionary *d in arr)
        {
          if([d[@"Id"] isEqualToString:pos.positionId])
          {
            found=YES;
            break;
          }
        }
        if(!found)
        {
          [_positions removeObjectAtIndex:i];
          i--;
        }
      }
    }
    
    _positionsLoaded = true;
    
    [self loadAllChartData];
    [self sendRefreshNotification];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MarginalDataLoaded" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountsChanged" object:nil];
    
  }];
}


-(void) reloadAssetPairs {
  NSURLRequest *request = [self createRequestWithAPI:@"init/accountinstruments" httpMethod:@"GET" getParameters:nil postParameters:nil];
  
  [self sendRequest:request completion:^(NSDictionary *response) {
    if ([response isKindOfClass:[NSDictionary class]]) {
      [self fillTradingConditions:response[@"Demo"][@"TradingConditions"] isDemo:YES];
      [self fillTradingConditions:response[@"Live"][@"TradingConditions"] isDemo:NO];
      
      [self sendRefreshNotification];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountsChanged" object:nil];
    }
  }];
}

- (void)reloadAccounts {
  NSURLRequest *request = [self createRequestWithAPI:@"init/accounts" httpMethod:@"GET" getParameters:nil postParameters:nil];
  
  [self sendRequest:request completion:^(NSDictionary *response) {
    if ([response isKindOfClass:[NSDictionary class]]) {
      
      [self fillAccounts:response[@"Demo"] isDemo:YES];
      [self fillAccounts:response[@"Live"] isDemo:NO];
      
      [self reloadAssetPairs];
    }
  }];
  
}


-(void)loadHistoryForAccount:(LWMarginalAccount *)account withCompletion:(void (^)(LWHistoryArray *, NSError *))completion
{
  
  NSDateFormatter *formatter = [NSDateFormatter new];
  [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
  
  NSString *toDateStr = [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@"Z"];
  
  NSString *fromDateStr = @"2016-12-16 19:25:52Z";
  
  NSMutableDictionary *parameters = [@{ @"From": fromDateStr, @"To": toDateStr, @"IsLive": (![account isDemo] ? @"true" : @"false") } mutableCopy];
  if ([account identity])
    parameters[@"AccountId"] = [account identity];
  
  NSURLRequest *request = [self createRequestWithAPI:@"accountshistory" httpMethod:@"GET" getParameters:parameters postParameters:nil];
  
  [self sendRequest:request completion:^(NSDictionary *response) {
    if ([response isKindOfClass:[NSDictionary class]]) {
      LWHistoryArray *array = [LWHistoryArray new];
      
      for (NSDictionary *dict in response[@"PositionsHistory"]) {
        LWMWHistoryPosition *pos = [[LWMWHistoryPosition alloc] initWithPosition:dict];
        if(pos) {
          [array addObjectsFromArray:pos.elements];
        }
      }
      
      for (NSDictionary *dict in response[@"Account"]) {
        LWMWHistoryPosition *pos = [[LWMWHistoryPosition alloc] initWithTransfer:dict];
        if(pos) {
          [array addObjectsFromArray:pos.elements];
        }
      }
      
      for(NSDictionary *dict in response[@"OpenPositions"]) {
        LWMWHistoryPosition *pos = [[LWMWHistoryPosition alloc] initWithPosition:dict];
        if(pos) {
          [array addObjectsFromArray:pos.elements];
        }
      }
      
      completion(array, nil);
    } else {
      if ([response isKindOfClass:[NSError class]]) {
        completion(nil, (NSError *)response);
      } else {
        completion(nil, [NSError errorWithDomain:@"" code:0 userInfo:@{ kErrorMessage: Localize(@"marginal.error.history") }]);
      }
    }
  }];
  
}

-(void) subscribeForUsersTopic
{
  if(![LWKeychainManager instance].notificationsTag) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self subscribeForUsersTopic];
    });
    return;
  }
  
  NSString *tag = [LWKeychainManager instance].notificationsTag;
  
  [wamp subscribe:[@"user." stringByAppendingString:tag] onEvent:^(MDWampEvent *result) {
    if(result.arguments.count)
    {
      for(NSDictionary *d in result.arguments)
      {
        if([d[@"Type"] intValue]==1)
        {
          NSDictionary *entity=d[@"Entity"];
//          [LWMarginalNotificationHelper checkReceivedPositionWithDict:entity];
          
          if([entity[@"Status"] intValue]==1 || [entity[@"Status"] intValue]==0)
          {
            
            [self updateOrAddPositionWithDict:d[@"Entity"]];
            
          }
          else if([entity[@"Status"] intValue]==2 || [entity[@"Status"] intValue]==3)
          {
            for(int i=0;i<_positions.count;i++)
            {
              LWMarginalPosition *p=_positions[i];
              if([p.positionId isEqualToString:entity[@"Id"]])
              {
                [_positions removeObject:p];
                [self stopListeningForAsset:p.assetPairId];
                break;
              }
            }
            
          }
          
          
          [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountsChanged" object:nil];
          
          
        }
        else if([d[@"Type"] intValue]==0)
        {
          NSDictionary *entity=d[@"Entity"];
          for(LWMarginalAccount *acc in _accounts)
          {
            if([acc.identity isEqualToString:entity[@"Id"]])
            {
              acc.balance=[entity[@"Balance"] doubleValue];
              //                            acc.collateral = [entity[@"Loan"] doubleValue];
              acc.withdrawTransferLimit = [entity[@"WithdrawTransferLimit"] doubleValue];
              //                            acc.isCurrent=[entity[@"IsCurrent"] boolValue];
              //                            if(acc.isCurrent) {
              //                                for(LWMarginalAccount *account in _accounts) {
              //                                    if(account!=acc) {
              //                                        account.isCurrent = false;
              //                                    }
              //                                }
              //                            }
              [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountsChanged" object:nil];
              
              break;
            }
          }
          
        }
        else if([d[@"Type"] intValue]==2) {
          NSDictionary *entity=d[@"Entity"];
          for(LWMarginalAccount *acc in _accounts)
          {
            if([acc.identity isEqualToString:entity[@"AccountId"]])
            {
              NSString *title = [NSString stringWithFormat:@"P&L %@ %@", [LWUtils formatVolume:[entity[@"TotalPnl"] doubleValue] accuracy:[LWCache accuracyForAssetId:acc.baseAssetId]], [LWCache displayIdForAssetId:acc.baseAssetId]];
              NSString *text = [NSString stringWithFormat:@"Margin Call, %d positions closed", [entity[@"PositionsCount"] intValue]];
                assert("Implement this if it is used");
//              [LWNotification showMarginCallWithTitle:title text:text];
              
              break;
            }
          }
          
          [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountsChanged" object:nil];
          
          
        }
        else if([d[@"Type"] intValue]==3) {
          NSDictionary *entity=d[@"Entity"];
          
          if([entity[@"UpdateAccounts"] boolValue]) {
            [self reloadAccounts];
          }
          else if([entity[@"UpdateAccountAssetPairs"] boolValue]) {
            [self reloadAssetPairs];
          }
        }
        
      }
    }
    
    [self sendRefreshNotification];
    
    
  } result:^(NSError *error) {
    if(error)
    {
      [self logErrorWithMessage:@"marginal.error.user_topic"];
      _flagListeningForAssets=NO;
    }
  }];
  
}

- (void)updateOrAddPositionWithDict:(NSDictionary *) d {
  BOOL found = NO;
  for (int i = 0; i < [self.positions count]; i++) {
    LWMarginalPosition *p = self.positions[i];
    if ([p.positionId isEqualToString:d[@"Id"]]) {
      found = YES;
      
      LWOrderType type = p.orderType;
      [p updateWithDictionary:d];
      if (p.status == LWPositionStatusClosed) {
        [self.positions removeObject:p];
        break;
      }
      if (type == LWOrderTypePosition && p.orderType == LWOrderTypeLimit) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [[NSNotificationCenter defaultCenter] postNotificationName:@"LimitOrderPlaced" object:nil];
        });
      }
      break;
    }
  }
  if (!found && [d[@"Status"] intValue] != 2) {
    LWMarginalPosition *pos = [[LWMarginalPosition alloc] initWithDictionary:d];
    [self.positions addObject:pos];
    [self startListeningForAsset:pos.assetPairId];
  }
  
}


#pragma mark - ACTIONS

-(void) depositToAccount:(LWMarginalAccount *) account amount:(double) amount completion:(void(^)(BOOL)) completion
{
    NSDictionary *dict=@{@"Token":[LWKeychainManager instance].token, @"AccountId":account.identity, @"Volume":@(amount)};
    
    [wamp call:@"account.deposit" payload:[self jsonStringFromDict:dict] complete:^(MDWampResult *result, NSError *error){
        completion(true);
    }];
}

-(void) withdrawFromAccount:(LWMarginalAccount *) account amount:(double) amount completion:(void(^)(BOOL)) completion
{
    NSDictionary *dict=@{@"Token":[LWKeychainManager instance].token, @"AccountId":account.identity, @"Volume":@(amount)};
    
    [wamp call:@"account.withdraw" payload:[self jsonStringFromDict:dict] complete:^(MDWampResult *result, NSError *error){
        completion(true);
    }];
}


-(void) createPosition:(LWMarginalPosition *) position withCompletion:(void(^)(NSString *)) completion
{
  
  LWMarginalAccount *acc;
  for(LWMarginalAccount *a in _accounts)
  {
    if(a.isCurrent)
    {
      acc=a;
      break;
    }
  }
  if(!acc)
  {
    [self logErrorWithMessage:@"marginal.error.no_current_account"];
    completion(false);
    return;
  }
  
  NSDictionary *dict = @{@"AccountId": acc.identity, @"Instrument": position.assetPairId, @"StopLoss": @(position.stopLoss), @"TakeProfit": @(position.takeProfit), @"Volume": position.isShortPosition ? @(-position.volume) : @(position.volume), @"FillType": @"FillOrKill"};
  
  if(position.limitOrderOpenPrice.doubleValue > 0) {
    NSMutableDictionary *newDict = [dict mutableCopy];
    newDict[@"ExpectedOpenPrice"] = position.limitOrderOpenPrice;
    dict = newDict;
  }
  
  NSURLRequest *request = [self createRequestWithAPI:@"orders/place" httpMethod:@"POST" getParameters:nil postParameters:dict];
  
  [self sendRequest:request completion:^(NSDictionary *response) {
    if ([response isKindOfClass:[NSDictionary class]]) {
      NSInteger status = [response[@"Status"] intValue];
      if (status == 1 || status == 0) {
        completion(nil);
      }       else {
        id rejectReason = response[@"RejectReasonText"];
        if (rejectReason && [rejectReason isKindOfClass:[NSString class]]) {
          completion(rejectReason);
        } else {
          completion(Localize(@"marginal.error.problems"));
        }
      }
    } else {
      completion(Localize(@"marginal.error.problems"));
    }
  }];
 
}

- (void)closePosition:(LWMarginalPosition *)position {
  NSString *method = nil;
  if(position.orderType == LWOrderTypePosition) {
    method = @"orders/close";
  } else {
    method = @"orders/cancel";
  }
  
  NSURLRequest *request = [self createRequestWithAPI:method
                            httpMethod:@"POST"
                         getParameters:nil
                        postParameters:@{ @"OrderId": position.positionId,
                                          @"AccountId": position.accountId }];
  
  [self sendRequest:request completion:^(NSDictionary *response) {
    if ([response isKindOfClass:[NSError class]]) {
      [self logErrorWithMessage:((NSError *)response).localizedDescription];
    } else if (![(id)response boolValue]) {
      [self logErrorWithMessage:@"marginal.error.problems"];
    }
  }];
}

- (void)changePositionLimits:(LWMarginalPosition *)position withCompletion:(void(^)(NSString *))completion {
  NSDictionary *dict = @{@"OrderId": position.positionId,
                         @"StopLoss": @(position.stopLoss),
                         @"TakeProfit": @(position.takeProfit),
                         @"AccountId": position.accountId};
  
  if (position.limitOrderOpenPrice.doubleValue > 0 && position.orderType == LWOrderTypeLimit) {
    NSMutableDictionary *newDict = [dict mutableCopy];
    newDict[@"ExpectedOpenPrice"] = position.limitOrderOpenPrice;
    newDict[@"Volume"] = position.isShortPosition ? @(-position.volume) : @(position.volume);
    dict = newDict;
  }
  
  NSURLRequest *requst = [self createRequestWithAPI:@"orders/limits" httpMethod:@"PUT" getParameters:nil postParameters:dict];
  
  [self sendRequest:requst completion:^(NSDictionary *response) {
    if (response == nil) {
      completion(@"API call failed");
    } else if ([response isKindOfClass:[NSError class]]) {
      completion(((NSError *)response).localizedDescription);
    } else if ([response isKindOfClass:[NSNumber class]] && [(NSNumber *)response boolValue] == true) {
      completion(nil);
    } else {
      completion(Localize(@"marginal.error.problems"));
    }
  }];
}

-(void) sendRefreshNotification {
  if(CACurrentMediaTime() - lastNotificationSentTime > kMinNotificationUpdateInterval) {
    [self sendNotification:@"PricesChanged"];
    lastNotificationSentTime = CACurrentMediaTime();
  }
}

- (void)sendChartDataFetchedNotification {
  if (CACurrentMediaTime() - lastChartDataNotificationSentTime > kMinNotificationUpdateInterval) {
    [self sendNotification:kChartDataFetchedNotification];
    lastChartDataNotificationSentTime = CACurrentMediaTime();
  }
}

- (void)sendNotification:(NSString *)notification {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
  });
}

- (NSMutableArray *) assets {
  if ([_accounts count] == 0 || [_assets count] == 0) {
    return nil;
  }
  
  LWMarginalAccount *account = [self currentAccount];
  if (account != nil) {
    NSMutableArray *accountAssets = [[NSMutableArray alloc] init];
    NSArray *assetsSnapshot = [NSArray arrayWithArray:_assets];
    for(LWMarginalWalletAsset *asset in assetsSnapshot) {
      if(asset.account == account) {
        [accountAssets addObject:asset];
      }
    }
    return accountAssets;
  }
  
  return nil;
}

-(NSArray *) allAssets {
  return _assets;
}


-(void) transportDidFailWithError:(NSError *)error
{
  
}

-(void) transportDidReceiveMessage:(NSData *)message
{
  
}

-(LWMarginalAccount *) currentAccount {
  LWMarginalAccount *acc;
  for(LWMarginalAccount *a in _accounts) {
    if(a.isCurrent) {
      acc = a;
      break;
    }
    
  }
  
  return acc;
}

-(NSString *) jsonStringFromDict:(NSDictionary *) dict
{
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                     options:0
                                                       error:nil];
  
  return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  
}

-(void) fillAccounts:(NSArray *) array isDemo:(BOOL) isDemo{
  if(!_accounts)
    _accounts=[[NSMutableArray alloc] init];
  
  //    for(LWMarginalAccount *acc in _accounts) {
  //        BOOL accFound = false;
  //        for(NSDictionary *d in array)
  //        {
  //            if([acc.identity isEqualToString:d[@"Id"]])
  //            {
  //                accFound = true;
  //                break;
  //            }
  //        }
  //        if(accFound == false) {
  //            [_accounts removeObject:acc];
  //        }
  //    }
  
  for(NSDictionary *d in array)
  {
    BOOL accFound=NO;
    for(LWMarginalAccount *acc in _accounts)
    {
      if([acc.identity isEqualToString:d[@"Id"]])
      {
        acc.balance=[d[@"Balance"] doubleValue];
        acc.withdrawTransferLimit = [d[@"WithdrawTransferLimit"] doubleValue];
        //                acc.collateral = [d[@"Loan"] doubleValue];
        //                acc.isCurrent=[d[@"IsCurrent"] boolValue];
        accFound=YES;
        break;
      }
    }
    if(accFound==NO)
    {
      LWMarginalAccount *newAccount = [[LWMarginalAccount alloc] initWithDict:d];
      newAccount.isDemo = isDemo;
      [_accounts addObject:newAccount];
    }
  }
  
}

- (void)createAssets:(NSArray *)array {
  if(!_assets) {
    _assets = [[NSMutableArray alloc] init];
  }
  for (NSDictionary * d in array) {
    NSArray *assetsSnapshot = [NSArray arrayWithArray:_assets];
    for (LWMarginalWalletAsset *asset in assetsSnapshot) {
      if ([d[@"Id"] isEqualToString:asset.identity]) {
        continue;
      }
    }
    LWMarginalWalletAsset *asset=[[LWMarginalWalletAsset alloc] initWithDict:d];
    [_assets addObject:asset];
  }
}

-(void) fillTradingConditions:(NSDictionary *) conditions isDemo:(BOOL) isDemo {
  NSMutableArray *currentAccounts = [[NSMutableArray alloc] init];
  for(LWMarginalAccount *acc in _accounts) {
    if(acc.isDemo == isDemo) {
      [currentAccounts addObject:acc];
    }
  }
  for(NSString *baseAssetId in conditions.allKeys) {
    NSArray *arr = conditions[baseAssetId];
    LWMarginalAccount *account;
    for(LWMarginalAccount *acc in currentAccounts) {
      if([acc.baseAssetId isEqualToString:baseAssetId]) {
        account = acc;
        break;
      }
    }
    
    for(NSDictionary *d in arr) {
      LWMarginalWalletAsset *foundAsset = nil;
      BOOL foundExactly = NO;
      NSArray *assetsSnapshot = [NSArray arrayWithArray:_assets];
      for (LWMarginalWalletAsset *asset in assetsSnapshot) {
        if([asset.identity isEqualToString:d[@"Instrument"]]) {
          if(asset.account == account) {
            [asset updateWithDict:d];
            foundExactly = YES;
            break;
          }
          else {
            foundAsset = asset;
          }
        }
      }
      if(foundExactly == NO && foundAsset != nil) {
        if (foundAsset.account == nil) {
          foundAsset.account = account;
          [foundAsset updateWithDict:d];
        } else {
          LWMarginalWalletAsset *newAsset = [foundAsset copy];
          newAsset.account = account;
          [newAsset updateWithDict:d];
          [_assets addObject:newAsset];
        }
      }
    }
  }
}



- (void)fillChartData:(NSDictionary *)chartData {
  NSArray *assetsSnapshot = [NSArray arrayWithArray:_assets];
  for (NSString *assetId in chartData.allKeys) {
    NSArray *changes = chartData[assetId];
    
    NSMutableArray *rates = @[].mutableCopy;
    for (NSDictionary *n in changes) {
      LWMarginalWalletRate *rate = [LWMarginalWalletRate new];
      rate.ask = [n[@"Ask"] doubleValue];
      rate.bid = [n[@"Bid"] doubleValue];
      
      NSDate *date = [n[@"Date"] toDateWithMilliSeconds];
      rate.timestamp = [date timeIntervalSinceReferenceDate];
      
      [rates addObject:rate];
    }
    
    for (LWMarginalWalletAsset *asset in assetsSnapshot) {
      if ([asset.identity isEqualToString:assetId]) {
        [asset.changes removeAllObjects];
        [asset ratesChanged:rates];
      }
    }
  }
}

#pragma mark - Auth Manager Callbacks

- (void)authManagerDidGetMarginChartData:(LWPacketMarginChartData *)pack {
  [self receivedChartData:pack.chartData forAssets:pack.assetIds];
}

- (void)receivedChartData:(NSDictionary *)chartData forAssets:(NSArray *)assetIds {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    if (chartData == nil) {
      [self logErrorWithMessage:@"marginal.error.no_graph"];
      return;
    }
    
    [self fillChartData:chartData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([LWKeychainManager instance].isAuthenticated == NO) {
        return;
      }
      
      [self sendChartDataFetchedNotification];
      [self sendRefreshNotification];
      
      if (assetIds) {
        for (NSString *assetId in assetIds) {
          [self startListeningForAsset:assetId];
        }
      }
      else {
        [self startListeningForAssets];
      }
    });
  });
}

#pragma mark - Helper

- (void)logErrorWithMessage:(NSString *)message {
  
}

@end
