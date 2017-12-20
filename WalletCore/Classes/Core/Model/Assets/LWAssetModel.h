//
//  LWAssetModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"

extern NSString * const kBTC_ID;
extern NSString * const kETH_ID;
extern NSString * const kETH_GUID;

typedef NS_ENUM(NSInteger, LWBlockchainType) {
  LWBlockchainTypeBitcoint = 0,
  LWBlockchainTypeEthereum,
  LWBlockchainTypeNone
};

@interface LWAssetModel : LWJSONObject

#pragma mark - Properties

@property (readonly) LWBlockchainType blockchainType;

@property (readonly, nonatomic) NSString *identity;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *fullName;
@property (readonly, nonatomic) NSString *symbol;
@property (readonly, nonatomic) NSString *displayId;
@property (readonly, nonatomic) NSNumber *accuracy;

@property (readonly, nonatomic) NSString *issuerId;
@property (readonly, nonatomic) NSString *categoryId;

@property (readonly, nonatomic) NSString *iconUrlString;

@property (strong, nonatomic) NSString *blockchainDepositAddress;

@property (strong, nonatomic) NSString *assetType;

@property (assign, nonatomic) BOOL visaDeposit;
@property (assign, nonatomic) BOOL swiftDeposit;
@property (assign, nonatomic) BOOL blockchainDeposit;
@property (assign, nonatomic) BOOL buyScreen;

@property (assign, nonatomic) BOOL visaWithdraw;
@property (assign, nonatomic) BOOL swiftWithdraw;
@property (assign, nonatomic) BOOL blockchainWithdraw;
@property (assign, nonatomic) BOOL sellScreen;

@property (assign, nonatomic) BOOL crossChainWithdrawal;  //Flag another blockchain (not Bitcoin). For SLR, ETH etc.

@property (assign, nonatomic) BOOL forwardWithdrawal; //Flag settlement is possible
@property (readonly, nonatomic) NSString *forwardWithdrawalBaseAssetId;
@property (readonly, nonatomic) NSInteger forwardFrozenDays;
@property (strong, nonatomic) NSString *forwardWithdrawalMemorandumUrl;

@property (readonly, nonatomic) BOOL hideWithdraw;

@property (readonly, nonatomic) BOOL bankCardDepositEnabled;
@property (readonly, nonatomic) BOOL swiftDepositEnabled;
@property (readonly, nonatomic) BOOL blockchainDepositEnabled;

@property (readonly, nonatomic) BOOL isErc20;
@property (readonly, nonatomic, getter = isTrusted) BOOL trusted;
#pragma mark - Root

+ (NSString *)assetByIdentity:(NSString *)identity fromList:(NSArray *)list;

@end
