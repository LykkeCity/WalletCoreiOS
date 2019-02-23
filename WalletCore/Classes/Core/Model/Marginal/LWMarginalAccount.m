//
//  LWMarginalAccount.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 11/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMarginalAccount.h"
#import "LWMarginalWalletsDataManager.h"
#import "LWMarginalPosition.h"
#import "LWUserDefault.h"

@interface LWMarginalAccount()
{
    double availableCalculated;
    double marginCalculated;
    double pnlCalculated;
    double totalCalculated;
    int openPositionsCalculated;
}

@end

@implementation LWMarginalAccount

- (instancetype)initWithDict:(NSDictionary *)dict {
  self=[super init];
  if (self) {
    _collateral = 0;
    _withdrawTransferLimit = [dict[@"WithdrawTransferLimit"] doubleValue];
    _transferType = [dict[@"FundsTransferType"] isEqualToString:@"Loan"] ? LWFoundsTransferTypeLoan : LWFoundsTransferTypeDirect;
    _identity=dict[@"Id"];
    _userId=dict[@"UserId"];
    _baseAssetId=dict[@"BaseAssetId"];
    _balance=[dict[@"Balance"] doubleValue];
    _isDemo = true;
  }
  return self;
}

- (void)setIsCurrent:(BOOL)isCurrent {
  [LWUserDefault instance].currentMarginalAccountId = self.identity;
}

- (BOOL)isCurrent {
    return [[LWUserDefault instance].currentMarginalAccountId isEqualToString:_identity];
}

-(void) calc:(BOOL) flagLowMargin
{
    NSArray *positions=[LWMarginalWalletsDataManager shared].positions;
    if(!positions)
        return;
    
    double totalPNL=0;
    double margin=0;
    int positionsCount=0;
    for(LWMarginalPosition *pos in positions)
    {
        if([pos.accountId isEqualToString:_identity])
        {
            positionsCount++;
            totalPNL+=pos.pAndL;
            if(flagLowMargin) {
                margin+=pos.marginLowLeverage;
            }
            else {
                margin+=pos.margin;
            }
        }
    }
    
    openPositionsCalculated=positionsCount;
    
    pnlCalculated=totalPNL;
    marginCalculated=margin;
    availableCalculated=_balance-marginCalculated+pnlCalculated;
    totalCalculated = _balance + pnlCalculated;
//    ((bal+pnl)-marg)/_balance
//    marg/(_balance+pnl)+
}

-(double) totalCapital {
    [self calc:NO];
    return totalCalculated;
}

-(double) margin
{
    [self calc:NO];
    return marginCalculated;
}

-(double) profitLoss
{
    [self calc:NO];
    return pnlCalculated;
}

-(double) availableBalance
{
    [self calc:NO];
    if(availableCalculated < 0) {
        return 0;
    }
    return availableCalculated;
}

-(int) openPositionsCount
{
    [self calc:NO];
    return openPositionsCalculated;
}

-(double) availableBalanceWithLowLeverage
{
    [self calc:true];
    if(availableCalculated < 0) {
        return 0;
    }
    return availableCalculated;
}



@end


//  "Id": "bc0ac1d7066f4ddd96b4e196efc97bd8",
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
