
//
//  LWMarginalWalletsDataManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMarginalWalletsDataManager.h"
#import "MDWamp.h"
#import "LWMarginalWalletAsset.h"
#import "NSString+Date.h"
#import "LWKeychainManager.h"
#import "LWMarginalAccount.h"
#import "LWMarginalPosition.h"
#import "LWMWHistoryElement.h"
#import "LWHistoryArray.h"

#import "LWUtils.h"
#import "LWCache.h"
//#import "LykkeSwift.h"
#import "AFNetworking.h"

@import UIKit;

@interface LWMarginalWalletsDataManager() <MDWampClientDelegate, MDWampTransportDelegate>
{
    MDWamp *wamp;
    BOOL flagConnected;
    
    
    NSMutableArray *listeningOrderbooks;
    
    double lastNotificationSentTime;
    
    NSMutableArray *assetsTemplates;
}

@end

@implementation LWMarginalWalletsDataManager

-(id) init
{
    self=[super init];
    
    lastNotificationSentTime = 0;
    _flagListeningForAssets = NO;
    _positionsLoaded = false;
    
    listeningOrderbooks=[[NSMutableArray alloc] init];
    _positions=[[NSMutableArray alloc] init];
    
    
    return self;
}

+ (instancetype)shared
{
    if([LWCache instance].flagShowMarginWallets == false) {
        return nil;
    }
    static LWMarginalWalletsDataManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LWMarginalWalletsDataManager alloc] init];
        
    });
    return shared;
}


-(void) start
{
    if([AFNetworkReachabilityManager sharedManager].isReachable && [LWCache instance].wampServerUrl) {
        wamp.delegate=nil;
        [wamp disconnect];
        
        flagConnected=NO;
        _flagListeningForAssets=NO;
        
        NSURL *url = [NSURL URLWithString:[LWCache instance].wampServerUrl];
        
        //        MDWampTransportWebSocket *websocket = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://13.93.116.252:5000/ws"] protocolVersions:@[kMDWampProtocolWamp2msgpack, kMDWampProtocolWamp2json]];
        MDWampTransportWebSocket *websocket = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:[LWCache instance].wampServerUrl] protocolVersions:@[kMDWampProtocolWamp2msgpack, kMDWampProtocolWamp2json]];
        
        
        wamp = [[MDWamp alloc] initWithTransport:websocket realm:@"mtcrossbar" delegate:self];
        
        [wamp connect];

    
    }
    else {
        if([LWKeychainManager instance].token) {
//            [[AFNetworkReachabilityManager sharedManager] startMonitoring];
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
 //   _assets = [[NSMutableArray alloc] init];
    _assets = nil;
}

// Called when client has connected to the server
- (void) mdwamp:(MDWamp*)wamp sessionEstablished:(NSDictionary*)info
{
    flagConnected=YES;
    
    [self loadInitialData];
    
}

// Called when client disconnect from the server
- (void) mdwamp:(MDWamp *)wamp closedSession:(NSInteger)code reason:(NSString*)reason details:(NSDictionary *)details
{
    NSLog(@"WAMP disconnected!!!");
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

-(void) startListeningForOrderBook:(NSString *) assetId
{
    if(!flagConnected)
    {
        [wamp connect];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startListeningForOrderBook:assetId];
        });
        return;
    }
    if(flagConnected==NO)
        return;

    if([listeningOrderbooks containsObject:assetId])
        return;
    [listeningOrderbooks addObject:assetId];
    NSString *channel=[@"orderbook.update." stringByAppendingString:assetId];
    [wamp subscribe:channel onEvent:^(MDWampEvent *payload) {
        
        
        
        // do something with the payload of the event
        NSLog(@"received %@ orderbook update %@", assetId, payload.arguments);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(payload.arguments.count==1)
            {
                
            }
            
            
        });
        
    } result:^(NSError *error) {
        if(error)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Failed to subscribe to prices update channel" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [listeningOrderbooks removeObject:assetId];
        }
        else
        {
            [wamp call:@"orderbook.init" payload:assetId complete:^(MDWampResult *result, NSError *error){
                
                
            }];
            
            
        }
    }];

    

}

-(void) startListeningForAssets
{

    [wamp subscribe:@"prices.update" onEvent:^(MDWampEvent *payload) {
        
        // do something with the payload of the event
//        NSLog(@"received an event %@", payload.arguments);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *changedAssetId=nil;
            
            BOOL flagWasChange = false;
            
            if(payload.arguments.count==1)
            {
                if(!_assets)
                    return;
                NSDictionary *dict=payload.arguments[0];
                
                
                LWMarginalWalletRate *rate=[LWMarginalWalletRate new];
                rate.ask=[dict[@"Ask"] doubleValue];
                rate.bid=[dict[@"Bid"] doubleValue];
                
                NSDate *date=[dict[@"Date"] toDateWithMilliSeconds];
                
                
                rate.timestamp=[date timeIntervalSinceReferenceDate];

                
                

                
                for(LWMarginalWalletAsset *asset in _assets)
                {
                    if([asset.identity isEqualToString:dict[@"Instrument"]])
                    {
                         flagWasChange = [asset rateChanged:rate];
                        
//                        if([asset.identity isEqualToString:@"BTCCHF"]) //testing
//                        {
//                            NSLog(@"received an event %@", payload.arguments);
//                        }
                        if(flagWasChange) {
                            changedAssetId=asset.identity;
                        }
                        break;
                    }
                }
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(changedAssetId)
                {
                    [self sendRefreshNotification];
                    [[NSNotificationCenter defaultCenter] postNotificationName:[@"PricesChanged" stringByAppendingString:changedAssetId]  object:nil];
                }

            });
        
        });
        
    } result:^(NSError *error) {
        if(error)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Failed to subscribe to prices update channel" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            _flagListeningForAssets=NO;
        }
        else {
            _flagListeningForAssets = true;
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
    
//    NSString *token = @"e53366d770f948f1a91b7cda6cb5954294182b18986f4197991f718484d68315";
    NSString *token = [LWKeychainManager instance].token;
    [wamp call:@"init.data" payload:token complete:^(MDWampResult *result, NSError *error){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if([LWKeychainManager instance].isAuthenticated == false) {
                return;
            }
            
        if(error || [result.arguments isKindOfClass:[NSArray class]]==NO || result.arguments.count!=1 || [result.arguments[0] isKindOfClass:[NSDictionary class]] == NO)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Failed to load Margin data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
                });
            return;
        }
        else
        {
            
            if(!_assets)
            {
                _assets=[[NSMutableArray alloc] init];
            }
            
            [self fillAccounts:result.arguments[0][@"Demo"][@"Accounts"] isDemo:YES];
            [self fillAccounts:result.arguments[0][@"Live"][@"Accounts"] isDemo:NO];
            
            if(_accounts.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ATTENTION" message:@"Unfortunately user has no Margin trading accounts" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
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
            
            [self createAssets:result.arguments[0][@"Assets"]];
            
            [self fillTradingConditions:result.arguments[0][@"Demo"][@"TradingConditions"]];
            [self fillTradingConditions:result.arguments[0][@"Live"][@"TradingConditions"]];
            
//            [self fillChartData:result.arguments[0][@"ChartData"]];
            
            
            if(_assets.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Failed to load Margin assets!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                });
                return;
            }

            
            dispatch_async(dispatch_get_main_queue(), ^{
//                if([LWKeychainManager instance].isAuthenticated == false) {
//                    return;
//                }
//                
//                [self startListeningForAssets];
//
//                [self sendRefreshNotification];
//                
//                [self getPositions];
//
////                [self testForExeption];
//
                [self loadChartData];
            });

            
        }
            });
    }];
    
//    [self subscribeForUsersTopic];
//    [self reloadAssetPairs];
}


-(void) loadChartData {
    NSString *token = [LWKeychainManager instance].token;
    [wamp call:@"init.graph" payload:@{} complete:^(MDWampResult *result, NSError *error){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if([LWKeychainManager instance].isAuthenticated == false) {
                return;
            }
            
            if(error || [result.arguments isKindOfClass:[NSArray class]]==NO || result.arguments.count!=1 || [result.arguments[0] isKindOfClass:[NSDictionary class]] == NO)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Failed to load Graph data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                });
                return;
            }
            else
            {
                
                
                
                
                [self fillChartData:result.arguments[0][@"ChartData"]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([LWKeychainManager instance].isAuthenticated == false) {
                        return;
                    }
                    
                    [self startListeningForAssets];
                    
                    [self sendRefreshNotification];
                    
                    [self getPositions];
                    
                    //                [self testForExeption];
                    
                });
                
                
            }
        });
    }];
    
    [self subscribeForUsersTopic];
    [self reloadAssetPairs];
}





-(void) getPositions
{
    NSError *error;
    [wamp call:@"order.list" payload:[LWKeychainManager instance].token complete:^(MDWampResult *result, NSError *error){
        
        if(result.arguments.count==1)
        {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [arr addObjectsFromArray:result.arguments[0][@"Demo"]];
            [arr addObjectsFromArray:result.arguments[0][@"Live"]];
            
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
        
        [self sendRefreshNotification];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MarginalDataLoaded" object:nil];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountsChanged" object:nil];


    }];
    
}


-(void) reloadAssetPairs {
    
    [wamp call:@"init.accountinstruments" payload:[LWKeychainManager instance].token complete:^(MDWampResult *result, NSError *error){
        if([result.arguments isKindOfClass:[NSArray class]] && [result.arguments count]>0 && [result.arguments[0] isKindOfClass:[NSDictionary class]]) {
            [self fillAssets:result.arguments[0][@"AccountAssetPairs"]];
            [self sendRefreshNotification];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountsChanged" object:nil];
        }
    }];
}

-(void) reloadAccounts {
    [wamp call:@"init.accounts" payload:[LWKeychainManager instance].token complete:^(MDWampResult *result, NSError *error){
        if([result.arguments isKindOfClass:[NSArray class]] && [result.arguments count]>0 && [result.arguments[0] isKindOfClass:[NSDictionary class]]) {
            [self fillAccounts:result.arguments[0][@"Live"] isDemo:NO];
            [self fillAccounts:result.arguments[0][@"Demo"] isDemo:YES];
//            [self reloadAssetPairs];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountsChanged" object:nil];

        }
    }];

}


-(void) loadHistoryForAccount:(LWMarginalAccount *)account withCompletion:(void (^)(NSArray *))completion
{

    
    NSDateFormatter *formatter=[NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *nowString=[formatter stringFromDate:[NSDate date]];
    formatter.timeZone=[NSTimeZone timeZoneWithName:@"UTC"];

    nowString = [nowString stringByAppendingString:@"Z"];
    NSMutableDictionary *dict=[@{@"Token":[LWKeychainManager instance].token, @"From":@"2016-12-16 19:25:52Z", @"To":nowString} mutableCopy];
    
    if(account) {
        dict[@"AccountId"] = account.identity;
    }

    [wamp call:@"account.history" payload:[self jsonStringFromDict:dict] complete:^(MDWampResult *result, NSError *error){
        
        LWHistoryArray *array = [LWHistoryArray new];
        if(result.arguments.count==1 && [result.arguments[0] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *d=result.arguments[0];
            
                for(NSDictionary *dict in d[@"PositionsHistory"]) {
                    LWMWHistoryPosition *pos = [[LWMWHistoryPosition alloc] initWithPosition:dict];
                    if(pos) {
                        [array addObjectsFromArray:pos.elements];
                    }
                }
            
            for(NSDictionary *dict in d[@"Account"]) {
                LWMWHistoryPosition *pos = [[LWMWHistoryPosition alloc] initWithTransfer:dict];
                if(pos) {
                    [array addObjectsFromArray:pos.elements];
                }
            }
            
            for(NSDictionary *dict in d[@"OpenPositions"]) {
                LWMWHistoryPosition *pos = [[LWMWHistoryPosition alloc] initWithPosition:dict];
                if(pos) {
                    [array addObjectsFromArray:pos.elements];
                }
            }


         }
        completion(array);
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
    
    NSString *tag = [LWKeychainManager instance].notificationsTag;//a4cf29683c2a4a09877651e5aa51851c
    
    [wamp subscribe:[@"user." stringByAppendingString:[LWKeychainManager instance].notificationsTag] onEvent:^(MDWampEvent *result) {
        NSLog(@"Received user event %@", result.arguments);
    
        if(result.arguments.count)
        {
            for(NSDictionary *d in result.arguments)
            {
                if([d[@"Type"] intValue]==1)
                {
                    NSDictionary *entity=d[@"Entity"];
//                    [LWMarginalNotificationHelper checkReceivedPositionWithDict:entity];

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
                            NSString *title = [NSString stringWithFormat:@"P&L %@ %@", [LWUtils formatVolume:[entity[@"TotalPnl"] doubleValue] accuracy:[LWCache accuracyForAssetId:acc.baseAssetId]], [[LWCache instance] currencySymbolForAssetId:acc.baseAssetId]];
                            NSString *text = [NSString stringWithFormat:@"Margin Call, %d positions closed", [entity[@"PositionsCount"] intValue]];
//                            [LWNotification showMarginCallWithTitle:title text:text];
                            
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
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Failed to subscribe user topic" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            _flagListeningForAssets=NO;
        }
    }];

}

-(void) updateOrAddPositionWithDict:(NSDictionary *) d
{
    BOOL found=NO;
    for(int i=0;i<_positions.count;i++)
    {
        LWMarginalPosition *p=_positions[i];
        if([p.positionId isEqualToString:d[@"Id"]])
        {
            found=YES;
            
            ORDER_TYPE type = p.orderType;
            [p updateWithDict:d];
            if(p.status == STATUS_CLOSED) {
                [_positions removeObject:p];
                break;
            }
            if(type == POSITION && p.orderType == LIMIT_ORDER) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LimitOrderPlaced" object:nil];
                });
            }
            break;
        }
    }
    if(!found && [d[@"Status"] intValue] != 2)
    {
        LWMarginalPosition *pos=[[LWMarginalPosition alloc] initWithDict:d];
        [_positions addObject:pos];
    }

}


#pragma ACTIONS

-(void) depositToAccount:(LWMarginalAccount *) account amount:(double) amount completion:(void(^)(BOOL)) completion
{
    
    NSDictionary *dict=@{@"Token":[LWKeychainManager instance].token, @"AccountId":account.identity, @"Volume":@(amount)};
    
    NSError *error;
    [wamp call:@"account.deposit" payload:[self jsonStringFromDict:dict] complete:^(MDWampResult *result, NSError *error){
        completion(true);
    }];
}

-(void) withdrawFromAccount:(LWMarginalAccount *) account amount:(double) amount completion:(void(^)(BOOL)) completion
{
    
    NSDictionary *dict=@{@"Token":[LWKeychainManager instance].token, @"AccountId":account.identity, @"Volume":@(amount)};
    
    NSError *error;
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
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Something wrong. Could not find current account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        completion(false);
        return;
    }
    
    
    NSDictionary *dict=@{@"Token":[LWKeychainManager instance].token, @"Order":@{@"AccountId":acc.identity, @"Instrument":position.assetPairId,  @"StopLoss":@(position.stopLoss), @"TakeProfit":@(position.takeProfit), @"Volume":position.flagShort?@(-position.volume):@(position.volume), @"FillType":@"FillOrKill"}};
    
    if(position.limitOrderOpenPrice.doubleValue > 0) {
        NSMutableDictionary *newDict = [dict mutableCopy];
        NSMutableDictionary *newOrder = [dict[@"Order"] mutableCopy];
        newOrder[@"ExpectedOpenPrice"] = position.limitOrderOpenPrice;
        newDict[@"Order"] = newOrder;
        dict = newDict;
    }
    
    NSLog(@"%@", dict);
    NSError *error;
    [wamp call:@"order.place" payload:[self jsonStringFromDict:dict] complete:^(MDWampResult *result, NSError *error){
        NSLog(@"Order placed %@", result.arguments);
        
        if(result.arguments.count) {
            if([result.arguments[0][@"Result"][@"Status"] intValue]==1 || [result.arguments[0][@"Result"][@"Status"] intValue]==0) {
                completion(nil);
            }
            else {
                id res=result.arguments[0][@"Result"][@"RejectReasonText"];
                if(res && [res isKindOfClass:[NSString class]]) {
                    completion(res);
                }
                else {
                    completion(@"We are experiencing technical problems. Please try again later.");
                }
            }
        }
        else {
            completion(@"We are experiencing technical problems. Please try again later.");
        }
        
    }];
    
}






-(void) closePosition:(LWMarginalPosition *) position
{
//    NSLog(@"ИТОГОВЫЙ РАСЧЕТ ******");
//    double pnl=position.pAndL;
    NSDictionary *dict=@{@"Token":[LWKeychainManager instance].token, @"OrderId":position.positionId, @"AccountId":position.accountId};
    
    NSString *rpc;
    if(position.orderType == POSITION) {
        rpc = @"order.close";
    }
    else {
        rpc = @"order.cancel";
    }
    
    [wamp call:rpc payload:[self jsonStringFromDict:dict] complete:^(MDWampResult *result, NSError *error){
        NSString *errStr = nil;

        if(result.arguments.count == 1 && [result.arguments[0][@"Result"] isKindOfClass:[NSNumber class]] && [result.arguments[0][@"Result"] boolValue] == false) {
            errStr = @"We are experiencing technical problems. Please try again later.";
            if([result.arguments[0][@"Message"] isKindOfClass:[NSString class]] && [result.arguments[0][@"Message"] length]>0) {
                errStr = result.arguments[0][@"Message"];
            }
            else if(error != nil) {
                errStr = error.localizedDescription;
            }
        }
        else if(error != nil) {
            errStr = error.localizedDescription;
        }
        if(errStr != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:errStr delegate:nil cancelButtonTitle:@"OK, I UNDERSTAND" otherButtonTitles: nil];
            [alert show];
        }
        
    }];
}

-(void) changePositionLimits:(LWMarginalPosition *) position withCompletion:(void(^)(NSString *)) completion
{
    NSDictionary *dict=@{@"Token":[LWKeychainManager instance].token, @"OrderId":position.positionId, @"StopLoss":@(position.stopLoss), @"TakeProfit":@(position.takeProfit), @"AccountId": position.accountId};
    
    if(position.limitOrderOpenPrice.doubleValue > 0 && position.orderType == LIMIT_ORDER) {
        NSMutableDictionary *newDict = [dict mutableCopy];
        newDict[@"ExpectedOpenPrice"] = position.limitOrderOpenPrice;
        newDict[@"Volume"] = position.flagShort?@(-position.volume):@(position.volume);
//        newDict[@"Volume"] = @(position.volume);
        dict = newDict;
    }
    
    NSError *error;
    [wamp call:@"order.changeLimits" payload:[self jsonStringFromDict:dict] complete:^(MDWampResult *result, NSError *error){
        if(result.arguments.count == 0) {
            completion(@"API call failed");
            return;
        }
        id res=result.arguments[0][@"Result"];
        if(res && [res isKindOfClass:[NSNumber class]] && [(NSNumber *)res boolValue] == true) {
            completion(nil);
        }
        else {
            completion(@"We are experiencing technical problems. Please try again later.");
        }

        
    }];
}

//-(void) changeCurrentAccountTo:(LWMarginalAccount *)account
//{
//    for(LWMarginalAccount *acc in _accounts)
//    {
//        acc.isCurrent=NO;
//    }
//    account.isCurrent=YES;
//        
//    NSDictionary *dict=@{@"Token":[LWKeychainManager instance].token, @"AccountId":account.identity};
//    NSError *error;
//    [wamp call:@"account.setActive" payload:[self jsonStringFromDict:dict] complete:^(MDWampResult *result, NSError *error){
//        [[LWAuthManager instance] requestCFDWatchLists];
//    }];
//
//}

-(void) sendRefreshNotification {
    if(CACurrentMediaTime() - lastNotificationSentTime > 0.1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PricesChanged" object:nil];
        });
        lastNotificationSentTime = CACurrentMediaTime();
    }
}

-(NSMutableArray *) assets {
    if(_accounts.count == 0 || _assets.count == 0) {
        return nil;
    }
    LWMarginalAccount *account = [self currentAccount];
    if(!account) {
        return nil;
    }
    
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    for(LWMarginalWalletAsset *asset in _assets) {
        if([asset.belongsToAccounts containsObject:account.baseAssetId]) {
            [assets addObject:asset];
        }
    }
    
    return assets;
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

-(void) createAssets:(NSArray *) array {
    _assets = [[NSMutableArray alloc] init];
    for(NSDictionary * d in array) {
        LWMarginalWalletAsset *asset=[[LWMarginalWalletAsset alloc] initWithDict:d];
        [_assets addObject:asset];
    }
}

-(void) fillTradingConditions:(NSDictionary *) conditions {
    for(NSString *identity in conditions.allKeys) {
        NSArray *arr = conditions[identity];

        for(NSDictionary *d in arr) {
            for(LWMarginalWalletAsset *asset in _assets) {
                if([asset.identity isEqualToString:d[@"Instrument"]]) {
                    [asset updateWithDict:d];
                    [asset.belongsToAccounts addObject:identity];
                }
            }
        }
    }
    
}

-(void) fillAssets:(NSDictionary *) dict {
//    for(NSString *key in dict.allKeys) {
//        NSArray *assetPairs = dict[key];
//        for(NSDictionary *d in assetPairs)
//        {
//            LWMarginalWalletAsset *asset;
//            for(LWMarginalWalletAsset *a in _assets)
//            {
//                if([a.identity isEqualToString:d[@"Id"]])
//                {
//                    asset=a;
//                    break;
//                }
//            }
//            if(!asset)
//            {
//                asset=[[LWMarginalWalletAsset alloc] initWithDict:d];
//            }
//            else {
//                [asset updateWithDict:d];
//            }
//            
//            if([asset.belongsToAccounts containsObject:key] == false) {
//                [asset.belongsToAccounts addObject:key];
//            }
//            
//            
//            if([_assets containsObject:asset] == false) {
//                [_assets addObject:asset];
//            }
//            
//        }
//    }

}

-(void) fillChartData:(NSDictionary *) chartData {
    
    for(int i=0;i<_assets.count;i++) {
        LWMarginalWalletAsset *asset = _assets[i];
        [asset.changes removeAllObjects];
        
        NSArray *changes=chartData[asset.identity];
        
        for(NSDictionary *n in changes)
        {
            LWMarginalWalletRate *rate=[LWMarginalWalletRate new];
            rate.ask=[n[@"Ask"] doubleValue];
            rate.bid=[n[@"Bid"] doubleValue];
            
            NSDate *date=[n[@"Date"] toDateWithMilliSeconds];
            
            
            rate.timestamp=[date timeIntervalSinceReferenceDate];
            [asset rateChanged:rate];
        }
        
    }


}




@end
