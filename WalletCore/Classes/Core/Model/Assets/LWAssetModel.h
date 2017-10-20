//
//  LWAssetModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"

typedef enum {BLOCKCHAIN_TYPE_BITCOIN, BLOCKCHAIN_TYPE_ETHEREUM, BLOCKCHAIN_TYPE_NONE} BLOCKCHAIN_TYPE;

@interface LWAssetModel : LWJSONObject {
    
}


#pragma mark - Properties

@property (readonly) BLOCKCHAIN_TYPE blockchainType;

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
//@property (readonly) BOOL hideDeposit;     теперь решаем по флагам ниже и по флагам получаемым при Auth


@property BOOL visaDeposit;
@property BOOL swiftDeposit;
@property BOOL blockchainDeposit;
@property BOOL buyScreen;

@property BOOL visaWithdraw;
@property BOOL swiftWithdraw;
@property BOOL blockchainWithdraw;
@property BOOL sellScreen;


@property BOOL crossChainWithdrawal;  //Flag another blockchain (not Bitcoin). For SLR, ETH etc.

@property BOOL forwardWithdrawal; //Flag settlement is possible
@property (readonly, nonatomic) NSString *forwardWithdrawalBaseAssetId;
@property int forwardFrozenDays;
@property (strong, nonatomic) NSString *forwardWithdrawalMemorandumUrl;


@property (readonly) BOOL hideWithdraw;

@property (readonly) BOOL bankCardDepositEnabled;
@property (readonly) BOOL swiftDepositEnabled;
@property (readonly) BOOL blockchainDepositEnabled;



#pragma mark - Root

+ (NSString *)assetByIdentity:(NSString *)identity fromList:(NSArray *)list;

@end
