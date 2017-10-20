//
//  LWMWHistoryPosition.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/01/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWMarginalAccount.h"
#import "LWMarginalWalletAsset.h"
#import "LWModel.h"
#import "LWMarginalPosition.h"

//OrderCloseReason
//None = 0
//Close = 1
//StopLoss = 2
//TakeProfit = 3
//StopOut = 4



@interface LWMWHistoryPosition : LWModel

-(id) initWithPosition:(NSDictionary *) dict;
-(id) initWithTransfer:(NSDictionary *) dict;

@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) NSString *assetId;

@property (strong, nonatomic) NSDate *openDate;
@property (strong, nonatomic) NSDate *closeDate;
@property double volume;
@property double totalPNL;
@property double openPrice;
@property double closePrice;
@property int accuracy;
@property double stopLoss;
@property double takeProfit;
@property CLOSE_REASON closeReason;

@property double interestRateSwapPNL;
@property double marketPNL;
@property double comission;

@property (strong, nonatomic) NSString *currencySymbol;

-(NSArray *) elements;

@end
