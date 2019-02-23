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

typedef NS_ENUM(NSInteger, LWOrderType) {
  LWOrderTypePosition,
  LWOrderTypeLimit
};

typedef NS_ENUM(NSInteger, LWPositionStatus) {
  LWPositionStatusWaiting,
  LWPositionStatusActive,
  LWPositionStatusClosed
};

typedef NS_ENUM(NSInteger, LWPositionCloseReason) {
  LWPositionCloseReasonNone = 0,
  LWPositionCloseReasonManual,
  LWPositionCloseReasonStopLoss,
  LWPositionCloseReasonTakeProfit,
  LWPositionCloseReasonMargin
};

@interface LWMarginalPosition : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (void)updateWithDictionary:(NSDictionary *)dict;

+ (double)expectedPNLForAsset:(LWMarginalWalletAsset *)asset account:(LWMarginalAccount *)account volume:(double)volume limit:(double)limit isShort:(BOOL)isShort fromPrice:(double)price position:(LWMarginalPosition *)position;

@property (readonly, nonatomic) LWMarginalAccount *account;
@property (readonly, nonatomic) LWMarginalWalletAsset *asset;

@property (strong, nonatomic) NSDate *openDate;

@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) NSString *positionId;
@property (strong, nonatomic) NSString *accountAssetId;
@property (strong, nonatomic) NSString *assetPairId;
@property (assign, nonatomic) double price;
@property (assign, nonatomic) double stopLoss;
@property (assign, nonatomic) double takeProfit;
@property (assign, nonatomic) double volume;
@property (assign, nonatomic, getter = isShortPosition) BOOL shortPosition;

@property (readonly, nonatomic) double pAndL;
@property (readonly, nonatomic) double margin;
@property (readonly, nonatomic) double marginLowLeverage;

@property (readonly, nonatomic) LWMarginalWalletRate *currentRate;

@property (readonly, nonatomic) LWOrderType orderType;
@property (readonly, nonatomic) LWPositionStatus status;
@property (readonly, nonatomic) LWPositionCloseReason closeReason;

@property (strong, nonatomic) NSNumber *limitOrderOpenPrice;

- (double)swapPNL;
- (double)marketPNL;

@end
