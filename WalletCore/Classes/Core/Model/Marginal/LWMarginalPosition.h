//
//  LWMarginalPosition.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 23/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LWMarginalWalletRate;
@class LWMarginalAccount;
@class LWMarginalWalletAsset;

typedef enum {POSITION, LIMIT_ORDER} ORDER_TYPE;
typedef enum {STATUS_WAITING, STATUS_ACTIVE, STATUS_CLOSED} POSITION_STATUS;

typedef enum {NONE = 0, MANUAL, STOP_LOSS, TAKE_PROFIT, MARGIN} CLOSE_REASON;


@interface LWMarginalPosition : NSObject

-(id) initWithDict:(NSDictionary *) d;
-(void) updateWithDict:(NSDictionary *) d;

+(double) expectedPNLForAsset:(LWMarginalWalletAsset *) asset account:(LWMarginalAccount *) account volume:(double) volume limit:(double) limit isShort:(BOOL) flagShort fromPrice:(double) price position:(LWMarginalPosition *)position;

@property (readonly) LWMarginalAccount *account;
@property (readonly) LWMarginalWalletAsset *asset;

@property (strong, nonatomic) NSDate *openDate;

@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) NSString *positionId;
@property (strong, nonatomic) NSString *accountAssetId;
@property (strong, nonatomic) NSString *assetPairId;
@property double price;
@property double stopLoss;
@property double takeProfit;
@property double volume;
@property BOOL flagShort;

@property (readonly) double pAndL;
@property (readonly) double margin;
@property (readonly) double marginLowLeverage;

@property (readonly) LWMarginalWalletRate *currentRate;

@property ORDER_TYPE orderType;

@property POSITION_STATUS status;

@property CLOSE_REASON closeReason;

@property (strong, nonatomic) NSNumber *limitOrderOpenPrice;

-(double) swapPNL;
-(double) marketPNL;

@end
