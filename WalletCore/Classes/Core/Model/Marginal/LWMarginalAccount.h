//
//  LWMarginalAccount.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 11/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWMarginalAccount : NSObject

-(id) initWithDict:(NSDictionary *) dict;

@property (strong, nonatomic) NSString *identity;
@property (strong, nonatomic) NSString *userId;
//@property double leverage;
@property (strong, nonatomic) NSString *baseAssetId;
@property double balance;
@property (readonly) double totalCapital;
@property (readonly) double availableBalance;

@property (readonly) double availableBalanceWithLowLeverage;

@property BOOL isCurrent;
@property (readonly) double margin;
//@property double freeMargin;
@property (readonly) double profitLoss;
@property (readonly) int openPositionsCount;

@property BOOL isDemo;

@end


//"Id": "bc0ac1d7066f4ddd96b4e196efc97bd8",
//"UserId": "b4d561925d0c4f72ac5489facfb5aa77",
//"Leverage": 100,
//"BaseAssetId": "EUR",
//"Balance": 50000,
//"AvailableBalance": 48760,
//"IsCurrent": true,
//"Margin": 200,
//"ProfitLoss": 5134.23,
//"FreeMargin": 200,
//"OpenPositionsCount": 16
